//
//  Serial.swift
//  Anime365
//
//  Created by Nikita Nafranets on 05.03.2023.
//

import Foundation
import SwiftUI

struct Serial: Identifiable {
    let id: Int
    let poster: UIImage
    let title: SerialTitle
    let rating: String
    let year: Int
    let season: SerialSeason
    let genres: [String]
    let numberOfEpisodes: Int
    let description: String?
    
}

struct SerialTitle {
    let ru: String
    let romaji: String
    let en: String?
}

enum SerialSeason: String {
    case winter = "Зима"
    case spring = "Весна"
    case summer = "Лето"
    case autumn = "Осень"
}


let exampleSerial = Serial(
    id: 26137,
    poster: UIImage(named: "anime-poster-1.jpg")!,
    title: SerialTitle(ru: "Семья шпиона. Часть 2 сезон", romaji: "Spy x Family Part 2", en: nil),
    rating: "8.35",
    year: 2022,
    season: .autumn,
    genres: [
    "Экшен",
    "Комедия",
    "Уход за детьми",
    "Сёнен"
], numberOfEpisodes: 13,
    description: "Как люди ни ценили бы искренность и правду, ложь продолжает оставаться неизбывной частью жизни и, как ни парадоксально звучит, зачастую счастливой жизни, залогом которой она и служит. Это абсолютно верно в случае семьи Форджеров, само существование которой — сплошной обман. Каждый член этой поддельной семьи врёт остальным, скрывая правду о себе.Лойд Форджер скрывает, что он секретный агент Весталиса. Йор Форджер умалчивает, что является наёмной убийцей, работающей в Остании. Тем не менее правда об их фиктивном браке и настоящих профессиях известна «дочери» Лойда, Ане, которую тот взял из приюта, не подозревая, что та не так проста, как кажется. Девочка, прошедшая через эксперименты, обрела способность читать чужие мысли.Пример этой фальшивой семьи подтверждает, что существует ложь во спасение. Особенно, когда на кону стоит ни много ни мало — мир во всём мире и жизни невинных людей!"
)


