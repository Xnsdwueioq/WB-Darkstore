//
//  ScreenState.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 07.09.2026.
//

import Foundation

public enum ScreenState<Content> {
    case loading
    case content(Content)
    case error(Error)
}
