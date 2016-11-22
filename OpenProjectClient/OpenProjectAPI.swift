//
//  OpenProjectAPIManager.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 14/06/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OpenProjectAPI {

    static let sharedInstance = OpenProjectAPI()
    fileprivate init() {}
    
    typealias RemoteRootResponse = (Instance?, NSError?) -> Void
    typealias RemoteProjectsResponse = ([Project]?, NSError?) -> Void
    typealias RemoteWorkpackagesResponse = ([WorkPackage]?, NSError?) -> Void
    typealias RemotePrioritiesStatusesTypesResponse = (Bool, NSError?) -> Void
    typealias RemoteAssigneesResponse = (Bool, NSError?) -> Void
    typealias RemoteResponsiblesResponse = (Bool, NSError?) -> Void
    typealias RemoteWorkPackageCreateFormsResponse = (JSON, NSError?) -> Void
    
    func getInstance(_ address: String, apikey: String, onCompletion: @escaping RemoteRootResponse) {
        
        let auth = getBasicAuth(apikey)
        
        let headers = [
            "Authorization": "\(auth)",
            "Accept": "application/hal+json"
        ]
        let url = "\(address)/api/v3"
        
        Alamofire.request(url, encoding: URLEncoding.default, headers: headers).validate().responseString { response in
            var instance = Instance.mr_createEntity() as Instance
            instance.address = address
            instance.apikey = apikey
            instance.auth = auth
            instance.id = NSUUID().uuidString
            switch response.result {
            case .success( _):
                guard let responseValue = response.result.value else {
                    onCompletion(instance, nil)
                    return
                }
                
                guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                    onCompletion(instance, nil)
                    return
                }
                
                let json = JSON(data: dataFromResponse)
                
                instance = Instance.buildInstance(instance, json: json)
                onCompletion(instance, nil)
                print("Root successfully received")
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                print("\(response)")
            case .failure(let error):
                print(error)
                onCompletion(nil, error as NSError?)
            }
        }
    }
    
    func getProjects(_ instanceId: String, onCompletion: @escaping RemoteProjectsResponse) {
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]

            let url = "\(instance.address!)/api/v2/projects.json?key=\(instance.apikey!)"

            Alamofire.request(url).validate().responseString { response in
                var projects = [Project]()
                switch response.result {
                case .success( _):
                    guard let responseValue = response.result.value else {
                        onCompletion(projects, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                        onCompletion(projects, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("Projects successfully received - \(json)")
                    Project.buildProjects(json)
                    projects = Project.mr_findAll() as! [Project]
                    onCompletion(projects, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(nil, error as NSError?)
                }
            }
        }
    }
    
    func getWorkPackagesByProjectId(_ projectId: NSNumber, instanceId: String, onCompletion: @escaping RemoteWorkpackagesResponse) {
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let filters = WPFilter.getWPFilter(projectId, instanceId: instanceId)
            
            let url = "\(instance.address!)/api/v3/projects/\(projectId)/work_packages?offset=1&pageSize=100\(filters)"
            
            Alamofire.request(url, headers: headers).validate().responseString { response in
                var workpackages = [WorkPackage]()
                switch response.result {
                case .success( _):
                    guard let responseValue = response.result.value else {
                        onCompletion(workpackages, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                        onCompletion(workpackages, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("Workpackages successfully received - \(json)")
                    WorkPackage.buildWorkpackages(projectId, instanceId: instanceId, json: json)
                    workpackages = WorkPackage.mr_findAll() as! [WorkPackage]
                    onCompletion(workpackages, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(nil, error as NSError?)
                }
            }
        }
    }
    
    func getWorkpackagesCreateForms(onCompletion: @escaping RemoteWorkPackageCreateFormsResponse) {
        
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)/api/v3/projects/\(NSNumber(value:projectId))/work_packages/form"
            
            Alamofire.request(url, method:.post, headers: headers).validate().responseString { response in
                switch response.result {
                case .success( _):
                    guard let responseValue = response.result.value else {
                        onCompletion(false, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                        onCompletion(false, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("WP Create forms successfully received - \(json)")

                    onCompletion(json, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    
    func getPrioritiesStatusesTypes(onCompletion: @escaping RemotePrioritiesStatusesTypesResponse) {
        
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        getWorkpackagesCreateForms(onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                let p = Priority.buildPriorities(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let t = Type.buildTypes(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let s = Status.buildStatuses(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                onCompletion(true, nil)
            }
        })
    }
    
    func getAvailableAssignees(onCompletion: @escaping RemoteAssigneesResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)/api/v3/projects/\(NSNumber(value:projectId))/available_assignees"
            
            Alamofire.request(url, method:.get, headers: headers).validate().responseString { response in
                switch response.result {
                case .success( _):
                    guard let responseValue = response.result.value else {
                        onCompletion(false, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                        onCompletion(false, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("Available assignees successfully received - \(json)")
                    Assignee.buildAssignees(NSNumber(value: projectId), instanceId:instanceId!, json: json, isAssignee: true)
                    onCompletion(true, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getAvailableResponsibles(onCompletion: @escaping RemoteResponsiblesResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)/api/v3/projects/\(NSNumber(value:projectId))/available_responsibles"
            
            Alamofire.request(url, method:.get, headers: headers).validate().responseString { response in
                switch response.result {
                case .success( _):
                    guard let responseValue = response.result.value else {
                        onCompletion(false, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                        onCompletion(false, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("Available responsibles successfully received - \(json)")
                    Assignee.buildAssignees(NSNumber(value: projectId), instanceId:instanceId!, json: json, isAssignee: false)
                    onCompletion(true, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    fileprivate func getHeaders(auth: String) -> [String : String] {
        return [
            "Authorization": "\(auth)",
            "Accept": "application/hal+json"
        ]
    }
    
    fileprivate func getBasicAuth(_ apiKey: String) -> String {
        let loginString = NSString(format: "apikey:%@", apiKey)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        return "Basic \(loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))"
    }
}
