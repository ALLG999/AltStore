//
//  RefreshAllAppsWidgetIntent.swift
//  AltStore
//
//  Created by Riley Testut on 8/18/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import AppIntents

@available(iOS 17, *)
struct RefreshAllAppsWidgetIntent: AppIntent, ProgressReportingIntent
{
    static var title: LocalizedStringResource { "通过小部件刷新应用程序" }
    static var isDiscoverable: Bool { false } // Don't show in Shortcuts or Spotlight.
    
    #if !WIDGET_EXTENSION
    private let intent = RefreshAllAppsIntent(presentsNotifications: true)
    #endif
    
    func perform() async throws -> some IntentResult
    {
    #if !WIDGET_EXTENSION
        do
        {
            _ = try await self.intent.perform()
        }
        catch
        {
            print("无法通过小部件刷新应用程序。", error)
        }
    #endif
        
        return .result()
    }
}

// To ensure this intent is handled by the app itself (and not widget extension)
// we need to conform to either `ForegroundContinuableIntent` or `AudioPlaybackIntent`.
// https://mastodon.social/@mgorbach/110812347476671807
//
// Unfortunately `ForegroundContinuableIntent` is marked as unavailable in app extensions,
// so we "conform" RefreshAllAppsWidgetIntent to it in an `unavailable` extension ¯\_(ツ)_/¯
@available(iOS, unavailable)
extension RefreshAllAppsWidgetIntent: ForegroundContinuableIntent {}
