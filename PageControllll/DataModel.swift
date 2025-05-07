//
//  DataModel.swift
//  PageControllll
//

import Foundation

struct Product {
    let name: String
    let descriptionXS: String
    let descriptionL: String
}

struct Category {
    let name: String
    let emoji: String
    let products: [Product]
}

extension Product {
    static let mobileDevices: [Product] = [
        Product(name: "iPhone 16 Pro Max", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 16 Pro", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 16", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 16 Plus", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 15 Pro Max", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 15 Pro", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 15", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 15 Plus", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 14 Pro Max", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 14 Pro", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 14", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 14 Plus", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 13 Pro Max", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 13 Pro", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 13", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 13 Mini", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 12 Pro Max", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        Product(name: "iPhone 12 Pro", descriptionXS: "Description XS 1", descriptionL: "Description L 1"),
        
        ]
    static let tablets: [Product] = [
        Product(name: "iPad", descriptionXS: "Description XS 1", descriptionL: "Description L 1")
        ]
    static let laptops: [Product] = [
        Product(name: "MacBook", descriptionXS: "Description XS 1", descriptionL: "Description L 1")
        ]
    
    static let virtualReality: [Product] = [
        Product(name: "Apple Vision Pro", descriptionXS: "Description XS 1", descriptionL: "Description L 1")
        ]
}   

extension Category {
    static let coreOfferings: [Category] = [
        Category(name: "Mobile Devices", emoji: "📱", products: Product.mobileDevices),
        Category(name: "Tablets", emoji: "📱", products: Product.tablets),
        Category(name: "Laptops", emoji: "", products: Product.laptops)
    ]

    static let researchAndDevelopment: [Category] = [
        Category(name: "Virtual Reality", emoji: "🔍", products: Product.virtualReality)
    ]
}