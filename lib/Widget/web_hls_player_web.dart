// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class WebHlsPlayer extends StatefulWidget {
  final String url;
  final String title;

  const WebHlsPlayer({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebHlsPlayer> createState() => _WebHlsPlayerState();
}

class _WebHlsPlayerState extends State<WebHlsPlayer> {
  late final String _viewType;
  late final String _elementId;

  @override
  void initState() {
    super.initState();
    _elementId = 'streamlive-video-${DateTime.now().microsecondsSinceEpoch}';
    _viewType = 'streamlive-hls-view-$_elementId';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final wrapper = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#000'
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      final video = html.VideoElement()
        ..id = _elementId
        ..controls = true
        ..autoplay = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#000';
      video.setAttribute('playsinline', 'true');
      video.setAttribute('webkit-playsinline', 'true');
      wrapper.children.add(video);

      final message = html.DivElement()
        ..id = '$_elementId-message'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.left = '0'
        ..style.display = 'none'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.textAlign = 'center'
        ..style.direction = 'rtl'
        ..style.padding = '24px'
        ..style.background = 'rgba(0, 0, 0, 0.72)'
        ..style.color = '#fff'
        ..style.fontFamily = 'Almarai, Arial, sans-serif'
        ..style.fontSize = '16px'
        ..style.lineHeight = '1.8';
      wrapper.children.add(message);

      _attachPlayer(video);
      return wrapper;
    });
  }

  void _attachPlayer(html.VideoElement video) {
    final urlJson = jsonEncode(widget.url);
    final elementIdJson = jsonEncode(_elementId);

    void runAttachScript() {
      final script = html.ScriptElement()
        ..type = 'text/javascript'
        ..text = '''
(function() {
  var source = $urlJson;
  var messageId = $elementIdJson + '-message';
  var waitingTimer = null;

  function setMessage(text, canRetry) {
    var box = document.getElementById(messageId);
    if (!box) return;
    if (!text) {
      box.style.display = 'none';
      box.innerHTML = '';
      return;
    }
    box.style.display = 'flex';
    box.innerHTML =
      '<div>' +
      '<div style="font-weight:700;font-size:18px;margin-bottom:8px;">' + text + '</div>' +
      '<div style="opacity:.82;margin-bottom:14px;">تأكد من الاشتراك أو جرّب قناة أخرى. إذا استمر الخلل تواصل مع الدعم.</div>' +
      (canRetry ? '<button id="' + messageId + '-retry" style="border:0;border-radius:8px;padding:10px 18px;background:#2fa9dc;color:white;cursor:pointer;font-family:inherit;">إعادة المحاولة</button>' : '') +
      '</div>';
    var retry = document.getElementById(messageId + '-retry');
    if (retry) retry.onclick = function() { attach(0); };
  }

  function clearWaitingTimer() {
    if (waitingTimer) {
      window.clearTimeout(waitingTimer);
      waitingTimer = null;
    }
  }

  function armWaitingTimer(video) {
    clearWaitingTimer();
    waitingTimer = window.setTimeout(function() {
      if (!video || video.readyState < 2) {
        setMessage('تعذر تحميل القناة حالياً', true);
      }
    }, 15000);
  }

  function attach(attempt) {
  var video = document.getElementById($elementIdJson);
  if (!video) {
    if (attempt < 80) {
      window.setTimeout(function() { attach(attempt + 1); }, 100);
    }
    return;
  }
  if (!source) return;
  setMessage('', false);
  clearWaitingTimer();
  video.pause();
  video.removeAttribute('src');
  video.load();
  video.onerror = function() {
    setMessage('تعذر تشغيل القناة حالياً', true);
  };
  video.onstalled = function() {
    armWaitingTimer(video);
  };
  video.onwaiting = function() {
    armWaitingTimer(video);
  };
  video.oncanplay = function() {
    clearWaitingTimer();
    setMessage('', false);
  };
  video.onplaying = function() {
    clearWaitingTimer();
    setMessage('', false);
  };
  if (source.indexOf('.m3u8') === -1) {
    video.src = source;
    armWaitingTimer(video);
    video.play().catch(function(){});
    return;
  }
  if (window.Hls && window.Hls.isSupported()) {
    if (video._streamliveHls) {
      video._streamliveHls.destroy();
    }
    var hls = new window.Hls({
      enableWorker: true,
      lowLatencyMode: true,
      backBufferLength: 90
    });
    video._streamliveHls = hls;
    hls.loadSource(source);
    hls.attachMedia(video);
    hls.on(window.Hls.Events.MANIFEST_PARSED, function() {
      armWaitingTimer(video);
      video.play().catch(function(){});
    });
    hls.on(window.Hls.Events.ERROR, function(event, data) {
      if (!data) return;
      if (data.details === 'fragLoadError' ||
          data.details === 'fragLoadTimeOut' ||
          data.details === 'manifestLoadError' ||
          data.details === 'manifestLoadTimeOut' ||
          data.fatal) {
        setMessage('تعذر تحميل بث القناة حالياً', true);
      }
    });
  } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
    video.src = source;
    armWaitingTimer(video);
    video.play().catch(function(){});
  } else {
    video.src = source;
    armWaitingTimer(video);
    video.play().catch(function(){});
  }
  }
  attach(0);
})();
''';
      html.document.body?.append(script);
      script.remove();
    }

    final existing = html.document.querySelector('script[data-hls-js="true"]');
    if (existing != null) {
      existing.onLoad.first.then((_) => runAttachScript());
      Future<void>.delayed(const Duration(milliseconds: 400), runAttachScript);
      return;
    }

    final loader = html.ScriptElement()
      ..src = 'https://cdn.jsdelivr.net/npm/hls.js@1.5.17/dist/hls.min.js'
      ..async = true;
    loader.setAttribute('data-hls-js', 'true');
    loader.onLoad.first.then((_) => runAttachScript());
    html.document.head?.append(loader);
  }

  @override
  void didUpdateWidget(covariant WebHlsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      final video = html.document.getElementById(_elementId);
      if (video is html.VideoElement) {
        _attachPlayer(video);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
