# Alpha

## 数据模型

### 模型键值的数据类型

1. String
2. Int
3. Double
4. Data
5. Object
6. JSONType

### 数据模型的声明

> 被注解修饰的属性会被写入键值

````swift
class a:Object{
    
    @Col
    var string:String = ""
    
    @NullableCol
    var stringw:String?
    
    @Col([.primary])
    var a:Int = 0
  
}
class b:Object{
    override var name: String{
        return "a"
    }
    @Col
    var strsdfsdfsi:String = ""
    
    @NullableCol
    var stringw:String?
    
    @Col([.primary])
    var a:Int = 0
}
class c:Object{
    @Col
    var cc:String = ""
    
    @NullableCol
    var bb:String?
    
    @Col
    var aa:Int = 0
    
    @NullableCol
    var fa:a?
  
  	@Col
    var json:JSONType = JSONType(json: JSON(nil))
}
````



