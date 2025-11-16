import Foundation

struct WgerExerciseResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [WgerExercise]
}

struct WgerExercise: Codable {
    let id: Int
    let name: String?
    let description: String?
    let category: Int?
    let muscles: [Int]?
    let musclesSecondary: [Int]?
    let equipment: [Int]?
    let language: Int?
    let images: [WgerExerciseImage]?
    let comments: [WgerExerciseComment]?
    let variations: Int?
    let uuid: String?
    let created: String?
    let lastUpdate: String?
    let licenseAuthor: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case muscles
        case musclesSecondary = "muscles_secondary"
        case equipment
        case language
        case images
        case comments
        case variations
        case uuid
        case created
        case lastUpdate = "last_update"
        case licenseAuthor = "license_author"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        category = try container.decodeIfPresent(Int.self, forKey: .category)
        muscles = try container.decodeIfPresent([Int].self, forKey: .muscles)
        musclesSecondary = try container.decodeIfPresent([Int].self, forKey: .musclesSecondary)
        equipment = try container.decodeIfPresent([Int].self, forKey: .equipment)
        language = try container.decodeIfPresent(Int.self, forKey: .language)
        images = try container.decodeIfPresent([WgerExerciseImage].self, forKey: .images)
        comments = try container.decodeIfPresent([WgerExerciseComment].self, forKey: .comments)
        variations = try container.decodeIfPresent(Int.self, forKey: .variations)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        lastUpdate = try container.decodeIfPresent(String.self, forKey: .lastUpdate)
        licenseAuthor = try container.decodeIfPresent(String.self, forKey: .licenseAuthor)
    }
    
    init(id: Int, name: String?, description: String?, category: Int?, muscles: [Int]?, musclesSecondary: [Int]?, equipment: [Int]?, language: Int?, images: [WgerExerciseImage]?, comments: [WgerExerciseComment]?, variations: Int?, uuid: String?, created: String?, lastUpdate: String?, licenseAuthor: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.muscles = muscles
        self.musclesSecondary = musclesSecondary
        self.equipment = equipment
        self.language = language
        self.images = images
        self.comments = comments
        self.variations = variations
        self.uuid = uuid
        self.created = created
        self.lastUpdate = lastUpdate
        self.licenseAuthor = licenseAuthor
    }
}

struct WgerExerciseImage: Codable {
    let id: Int
    let image: String
    let isMain: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
        case isMain = "is_main"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        isMain = try container.decodeIfPresent(Bool.self, forKey: .isMain)
    }
}

struct WgerExerciseComment: Codable {
    let id: Int
    let comment: String
    let exercise: Int
}

struct WgerCategory: Codable {
    let id: Int
    let name: String
}

struct WgerCategoryResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [WgerCategory]
}

struct WgerExerciseInfo: Codable {
    let id: Int
    let uuid: String?
    let created: String?
    let lastUpdate: String?
    let category: WgerCategoryInfo?
    let muscles: [WgerMuscleInfo]?
    let musclesSecondary: [WgerMuscleInfo]?
    let equipment: [WgerEquipmentInfo]?
    let images: [WgerExerciseImage]?
    let translations: [WgerTranslationInfo]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case created
        case lastUpdate = "last_update"
        case category
        case muscles
        case musclesSecondary = "muscles_secondary"
        case equipment
        case images
        case translations
    }
    
    var name: String? {
        if let translations = translations {
            if let englishTranslation = translations.first(where: { $0.language == 2 }) {
                return englishTranslation.name
            }
            return translations.first?.name
        }
        return nil
    }
    
    var description: String? {
        if let translations = translations {
            if let englishTranslation = translations.first(where: { $0.language == 2 }) {
                return englishTranslation.description
            }
            return translations.first?.description
        }
        return nil
    }
}

struct WgerCategoryInfo: Codable {
    let id: Int
    let name: String
}

struct WgerMuscleInfo: Codable {
    let id: Int
    let name: String
    let nameEn: String?
    let isFront: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameEn = "name_en"
        case isFront = "is_front"
    }
}

struct WgerEquipmentInfo: Codable {
    let id: Int
    let name: String
}

struct WgerTranslationInfo: Codable {
    let id: Int
    let name: String
    let description: String?
    let language: Int?
}

struct WgerExerciseInfoResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [WgerExerciseInfo]
}

struct WgerLanguage: Codable {
    let id: Int
    let shortName: String
    let fullName: String
    let fullNameEn: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case shortName = "short_name"
        case fullName = "full_name"
        case fullNameEn = "full_name_en"
    }
}

struct WgerLanguageResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [WgerLanguage]
}

extension WgerExercise {
    init(from info: WgerExerciseInfo) {
        self.init(
            id: info.id,
            name: info.name,
            description: info.description,
            category: info.category?.id,
            muscles: info.muscles?.map { $0.id },
            musclesSecondary: info.musclesSecondary?.map { $0.id },
            equipment: info.equipment?.map { $0.id },
            language: info.translations?.first?.language,
            images: info.images,
            comments: nil,
            variations: nil,
            uuid: info.uuid,
            created: info.created,
            lastUpdate: info.lastUpdate,
            licenseAuthor: nil
        )
    }
}

