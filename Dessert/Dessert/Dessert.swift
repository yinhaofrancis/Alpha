//
//  Dessert.swift
//  Dessert
//
//
//
import UIKit

public protocol Initable{
    init()
}

extension UIView : Initable { }


public protocol Dessert{
    
    associatedtype Body:Dessert
    
    var body:Body { get }
    
    var type:Initable.Type { get }
    
}
extension Never: Dessert {
    public var type: Initable.Type {
        fatalError()
    }
    
    public typealias Body = Never
    
    public var body: Never { fatalError() }
    
}

public struct Empty:Dessert{
    
    public var type: Initable.Type = UIView.self
    
    
    public var body: Never{
        fatalError()
    }
    
    public typealias Body = Never
    
}

public typealias Desserts = any Dessert;

@resultBuilder
public struct DessertBuilder{
    public static func buildBlock(_ components: Desserts...) -> Desserts {
        return DessertContainer(container: components.map {$0})
    }
    
    public static func buildArray(_ components: [Desserts]) -> Desserts {
        let aa:[Desserts] = components.reduce(into: []) { partialResult, ds in
            if let des = ds as? DessertContainer{
                partialResult.append(contentsOf: des.container)
            }else{
                partialResult.append(ds)
            }
        }
        return DessertContainer(container: aa)
    }
    
    public static func buildEither(first component: Desserts) -> Desserts {
        return component
    }
    
    public static func buildEither(second component: Desserts) -> Desserts {
        return component
    }
    
    public static func buildLimitedAvailability(_ component: Desserts) -> Desserts {
        return component
    }
    public static func buildOptional(_ component: Desserts?) -> Desserts {
        DessertContainer(container: [])
    }
    
}

struct DessertContainer:Dessert{
    var type: Initable.Type = UIStackView.self
    

    typealias Body = Empty
    
    var body: Body { Empty() }
    
    var container:[Desserts]
}


public struct Label:Dessert{
    
    public var type: Initable.Type = UILabel.self
    
    public typealias Body = Empty

    public var body: Empty { Empty() }
    
    public var text:String
    
    public var font:UIFont
    
    public var textColor:UIColor
    
    public var align:NSTextAlignment
    
    public init(text: String, font: UIFont, textColor: UIColor, align: NSTextAlignment = .center) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.align = align
    }
}

public struct Stack:Dessert{
    
    public var type: Initable.Type = UIStackView.self
    
    public var axis:NSLayoutConstraint.Axis
        
    public var distribution:UIStackView.Distribution
    
    public var alignment:UIStackView.Alignment
    
    var container:DessertContainer
    
    public init(axis:NSLayoutConstraint.Axis,
                distribution:UIStackView.Distribution = .fill,
                alignment:UIStackView.Alignment = .fill,
                @DessertBuilder views: ()->Desserts){
        self.container = views() as! DessertContainer
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
    }
    
    public typealias Body = Empty
    
    public var body: Body { Empty() }
    
}
