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
    typealias RemoteWPCreateFormsResponse = (Bool, NSError?) -> Void
    typealias RemoteWPCreateFormsValidationResponse = (JSON, NSError?) -> Void
    typealias RemoteActivitiesListResponse = (Bool, NSError?) -> Void
    typealias RemoteUserResponse = (Bool, NSError?) -> Void
    typealias RemoteJSONResponse = (JSON, NSError?) -> Void
    
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
    
    func getWorkPackagesByProjectId(_ projectId: NSNumber, offset: Int, pageSize: Int, truncate: Bool, instanceId: String, onCompletion: @escaping RemoteWorkpackagesResponse) {
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let filters = WPFilter.getWPFilter(projectId, instanceId: instanceId)
            
            let url = "\(instance.address!)/api/v3/projects/\(projectId)/work_packages?offset=\(offset)&pageSize=\(pageSize)\(filters)"
            
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
                    WorkPackage.buildWorkpackages(projectId, instanceId: instanceId, truncate: truncate, json: json)
                    let predicate = NSPredicate(format: "instanceId = %i AND projectId = %i", argumentArray: [instanceId, projectId])
                    workpackages = WorkPackage.mr_findAllSorted(by: "id", ascending: true, with: predicate) as! [WorkPackage]
                    onCompletion(workpackages, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(nil, error as NSError?)
                }
            }
        }
    }

    func getWorkpackagesForms(wpId: Int32?, payload: String?, onCompletion: @escaping RemoteWorkPackageCreateFormsResponse) {

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
            
            var url = "\(instance.address!)/api/v3/projects/\(NSNumber(value:projectId))/work_packages/form"
            if let workPackageId = wpId {
                url = "\(instance.address!)/api/v3/work_packages/\(workPackageId)/form"
            }
            
            if payload != nil {
                Alamofire.request(url, method: .post, parameters: paramsFromJSON(json: payload!), encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
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
                        print("Validate form response successfully received")
                        onCompletion(json, nil)
                    case .failure(let error):
                        print(error)
                        print("\(url)")
                        print("\(payload!)")
                        onCompletion(false, error as NSError?)
                    }
                }
            } else {
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
                    print("\(url)")
                    onCompletion(false, error as NSError?)
                }
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func verifyWorkpackageFormPayload(wpId: Int32?, payload: String, onCompletion: @escaping RemoteWPCreateFormsValidationResponse) {
        
        getWorkpackagesForms(wpId: nil, payload: payload, onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                onCompletion(json, nil)
            }
        })
    }
    
    func createOrUpdateWorkpackage(wpId: Int32?, payload: String, onCompletion: @escaping RemoteWPCreateFormsValidationResponse) {
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
            
            var url = "\(instance.address!)/api/v3/projects/\(NSNumber(value:projectId))/work_packages"
            var method: HTTPMethod = .post
            var operationName = "Create"
            
            if let workPackageId = wpId {
                url = "\(instance.address!)/api/v3/work_packages/\(workPackageId)"
                method = .patch
                operationName = "Update"
            }
            
            Alamofire.request(url, method: method, parameters: paramsFromJSON(json: payload), encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
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
                    print("\(operationName) WP response successfully received")
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
    
    func getWorkpackagesCreateFormsPayload(onCompletion: @escaping RemoteWPCreateFormsResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        getWorkpackagesForms(wpId: nil, payload: nil, onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                WorkPackageFormSchema.buildWorkPackageForms(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                onCompletion(true, nil)
            }
        })
    }
    
    func getWorkpackagesUpdateFormsPayload(wpId: Int32, onCompletion: @escaping RemoteWPCreateFormsResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        getWorkpackagesForms(wpId: wpId, payload: nil, onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                WorkPackageFormSchema.buildWorkPackageForms(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                onCompletion(true, nil)
            }
        })
    }
    
    func getPrioritiesStatusesTypes(onCompletion: @escaping RemotePrioritiesStatusesTypesResponse) {
        
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        getWorkpackagesForms(wpId: nil, payload: nil, onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                let _ = Priority.buildPriorities(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let _ = Type.buildTypes(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let _ = Status.buildStatuses(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let _ = Version.buildVersions(NSNumber(value:projectId), instanceId: instanceId!, json: json)
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
    
    func getActivities(href: String, onCompletion: @escaping RemoteActivitiesListResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(href)"
            print("Sending activities request to \(url)")
            
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
                    print("Activities successfully received - \(json)")
                    WorkPackageActivity.buildWPActivities(json: json)
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
    
    func getUser(href: String, onCompletion: @escaping RemoteUserResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(href)"
            print("Sending user request to \(url)")
            
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
                    print("User successfully received - \(json)")
                    OpUser.buildOpUser(json: json)
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
    
    func getWatchers(href: String, onCompletion: @escaping RemoteUserResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(href)"
            print("Sending watchers request to \(url)")
            
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
                    print("Watchers successfully received - \(json)")
                    OpUser.buildWatchers(json: json)
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
    
    func sendActivityComment(payload: String, workPackageId: Int32, onCompletion: @escaping RemoteJSONResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)/api/v3/work_packages/\(workPackageId)/activities"
            print("Sending new activity comment to \(url)")
            
            Alamofire.request(url, method: .post, parameters: paramsFromJSON(json: payload), encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
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
                    print("Add comment response successfully received - \(json)")
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
    
    private func paramsFromJSON(json: String) -> [String : AnyObject]?
    {
        let objectData: NSData = (json.data(using: String.Encoding.utf8))! as NSData
        var jsonDict: [ String : AnyObject]!
        do {
            jsonDict = try JSONSerialization.jsonObject(with: objectData as Data, options: .mutableContainers) as! [ String : AnyObject]
            return jsonDict
        } catch {
            print("JSON serialization failed:  \(error)")
            return nil
        }
    }
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
