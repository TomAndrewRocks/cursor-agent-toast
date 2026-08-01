#!/usr/bin/osascript -l JavaScript
// macOS on-screen toast for Cursor agent "stop" hook.
// Invoked by notify.sh — not Notification Center.
//
// Setup (project root):
//   chmod +x .cursor/hooks/notify.sh .cursor/hooks/toast.js
// Manual test: osascript -l JavaScript .cursor/hooks/toast.js "test"
// Errors (background): cat /tmp/cursor-toast.err

ObjC.import("Cocoa");

function run(argv) {
  var message = argv.length > 0 ? argv[0] : "Agent finished";

  var app = $.NSApplication.sharedApplication;
  app.setActivationPolicy($.NSApplicationActivationPolicyAccessory);

  var screenFrame = $.NSScreen.mainScreen.frame;
  var width = 300;
  var height = 56;
  var marginRight = 24;
  var marginBottom = 54;

  var x = screenFrame.size.width - width - marginRight;
  var y = marginBottom;

  var rect = $.NSMakeRect(x, y, width, height);

  var win = $.NSWindow.alloc.initWithContentRectStyleMaskBackingDefer(
    rect,
    0,
    $.NSBackingStoreBuffered,
    false,
  );

  win.level = 25;
  win.opaque = false;
  win.backgroundColor = $.NSColor.clearColor;
  win.hasShadow = true;
  win.ignoresMouseEvents = true;
  win.collectionBehavior = 1;

  var content = $.NSView.alloc.initWithFrame($.NSMakeRect(0, 0, width, height));
  content.wantsLayer = true;
  content.layer.backgroundColor =
    $.NSColor.colorWithCalibratedRedGreenBlueAlpha(
      0.98,
      0.98,
      0.99,
      0.97,
    ).CGColor;
  content.layer.cornerRadius = 12;
  content.layer.masksToBounds = true;
  content.layer.borderColor = $.NSColor.colorWithCalibratedRedGreenBlueAlpha(
    0.82,
    0.84,
    0.88,
    1,
  ).CGColor;
  content.layer.borderWidth = 1;

  var icon = $.NSTextField.alloc.initWithFrame(
    $.NSMakeRect(16, height / 2 - 13, 26, 26),
  );
  icon.stringValue = "\u2705";
  icon.bezeled = false;
  icon.drawsBackground = false;
  icon.editable = false;
  icon.selectable = false;
  icon.font = $.NSFont.systemFontOfSize(18);

  var label = $.NSTextField.alloc.initWithFrame(
    $.NSMakeRect(48, height / 2 - 11, width - 64, 22),
  );
  label.stringValue = message;
  label.bezeled = false;
  label.drawsBackground = false;
  label.editable = false;
  label.selectable = false;
  label.textColor = $.NSColor.colorWithCalibratedRedGreenBlueAlpha(
    0.12,
    0.13,
    0.16,
    1,
  );
  label.font = $.NSFont.systemFontOfSize(13);

  content.addSubview(icon);
  content.addSubview(label);
  win.contentView = content;

  win.orderFront(null);

  var deadline = $.NSDate.dateWithTimeIntervalSinceNow(3.5);
  $.NSRunLoop.currentRunLoop.runUntilDate(deadline);
}
