import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var name = ""
    @objc dynamic var id = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func userExist (id: String, realm: Realm) -> Bool {
        return realm.object(ofType: User.self, forPrimaryKey: id) != nil
    }
    
    static func getOrCreate (id: String, realm: Realm) -> User {
        let user = realm.object(ofType: User.self, forPrimaryKey: id).or(else: {
            let u = User()
            u.id = id
            return u
        })
        
        try! realm.write {
            realm.add(user)
        }
        
        return user
        
    }
    
    func save(realm: Realm){
        try! realm.write {
            realm.add(self)
        }
    }
    
    func update(realm: Realm){
        try! realm.write {
            realm.add(self, update: true)
        }
    }
}
