#include "native-methods.h"

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>

namespace keyboard_auto_type {

pid_t native_frontmost_app_pid() {
    NSRunningApplication *app = [[NSWorkspace sharedWorkspace] frontmostApplication];
    return app ? app.processIdentifier : 0;
}

NativeAppInfo native_frontmost_app() {
    NSRunningApplication *app = [[NSWorkspace sharedWorkspace] frontmostApplication];
    if (!app) {
        return {};
    }
    NativeAppInfo result;
    result.pid = app.processIdentifier;
    result.name = app.localizedName.UTF8String;
    result.bundle_id = app.bundleIdentifier.UTF8String;
    return result;
}

bool native_show_app(pid_t pid) {
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    return app && [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

NativeWindowInfo native_window_info(pid_t pid) {
    NativeWindowInfo result{};

    id app = [SBApplication applicationWithProcessIdentifier:pid];

    // Chromium, equivalent of this AppleScript:
    // tell application "Google Chrome" to get URL of active tab of front window
    if ([app respondsToSelector:@selector(windows)]) {
        id windows = [app performSelector:@selector(windows)];
        if ([windows isKindOfClass:[NSArray class]] && [windows count]) {
            id window = [windows objectAtIndex:0];
            if ([window respondsToSelector:@selector(activeTab)]) {
                id active_tab = [window performSelector:@selector(activeTab)];
                if ([active_tab respondsToSelector:@selector(name)]) {
                    id name = [active_tab performSelector:@selector(name)];
                    if ([name isKindOfClass:[NSString class]]) {
                        result.title = [name UTF8String];
                    }
                }
                if ([active_tab respondsToSelector:@selector(URL)]) {
                    id url = [active_tab performSelector:@selector(URL)];
                    if ([url isKindOfClass:[NSString class]]) {
                        result.url = [url UTF8String];
                    }
                }
            }
        }
    }

    if (!result.url.empty() || !result.title.empty()) {
        return result;
    }

    // Safari, equivalent of this AppleScript:
    // tell application "Safari" to get URL of front document
    if ([app respondsToSelector:@selector(document)]) {
        id doc = [app performSelector:@selector(document)];
        if ([doc respondsToSelector:@selector(name)]) {
            id names = [doc performSelector:@selector(name)];
            if ([names isKindOfClass:[NSArray class]] && [names count]) {
                id name = [names objectAtIndex:0];
                if ([name isKindOfClass:[NSString class]]) {
                    result.title = [name UTF8String];
                }
            }
        }
        if ([doc respondsToSelector:@selector(URL)]) {
            id urls = [doc performSelector:@selector(URL)];
            if ([urls isKindOfClass:[NSArray class]] && [urls count]) {
                id url = [urls objectAtIndex:0];
                if ([url isKindOfClass:[NSString class]]) {
                    result.url = [url UTF8String];
                }
            }
        }
    }

    return result;
}

} // namespace keyboard_auto_type
