//
//  INInteraction+AltStore.swift
//  AltStore
//
//  Created by Riley Testut on 9/4/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

import Intents

extension INInteraction
{
    static func refreshAllApps() -> INInteraction
    {
        let refreshAllIntent = RefreshAllIntent()
        refreshAllIntent.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "刷新我的应用程序") as String
        
        let interaction = INInteraction(intent: refreshAllIntent, response: nil)
        return interaction
    }
}
