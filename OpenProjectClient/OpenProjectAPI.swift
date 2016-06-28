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

/*
protocol OpenProjectAPIManagerDelegate {
    func dataDownloadFinished(sender: OpenProjectAPIManager)
}
 */

class OpenProjectAPI {
    //var delegate: OpenProjectAPIManagerDelegate?
    static let sharedInstance = OpenProjectAPI()
    private init() {}
    
    typealias RemoteRootResponse = (Instance?, NSError?) -> Void
    
    typealias RemoteProjectsResponse = ([Project]?, NSError?) -> Void
    
    typealias RemoteWorkpackagesResponse = ([WorkPackage]?, NSError?) -> Void
    
    func getInstance(address: String, apikey: String, onCompletion: RemoteRootResponse) {
        
        let auth = getBasicAuth(apikey)
        
        let headers = [
            "Authorization": "\(auth)",
            "Accept": "application/hal+json"
        ]
        let url = "\(address)/api/v3"
        
        Alamofire.request(.GET, url, headers: headers).validate().responseString { response in
            var instance = Instance.MR_createEntity() as Instance
            instance.address = address
            instance.apikey = apikey
            instance.auth = auth
            instance.id = NSUUID().UUIDString
            switch response.result {
            case .Success:
                guard let responseValue = response.result.value else {
                    onCompletion(instance, nil)
                    return
                }
                
                guard let dataFromResponse = responseValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                    onCompletion(instance, nil)
                    return
                }
                
                let json = JSON(data: dataFromResponse)
                
                instance = Instance.buildInstance(instance, json: json)
                onCompletion(instance, nil)
                print("Root successfully received")
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                print("\(response)")
            case .Failure(let error):
                print(error)
                onCompletion(nil, error)
            }
        }
    }
    
    func getProjects(instanceId: String, onCompletion: RemoteProjectsResponse) {
        
        guard let instances = Instance.MR_findByAttribute("id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = [
                "Authorization": "\(instance.auth)",
                "Accept": "application/json"
            ]
            
            let url = "\(instance.address!)/api/v2/projects.json"
            
            Alamofire.request(.GET, url, headers: headers).validate().responseString { response in
                var projects = [Project]()
                switch response.result {
                case .Success:
                    guard let responseValue = response.result.value else {
                        onCompletion(projects, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                        onCompletion(projects, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("Projects successfully received - \(json)")
                    Project.buildProjects(json)
                    projects = Project.MR_findAll() as! [Project]
                    onCompletion(projects, nil)
                case .Failure(let error):
                    print(error)
                    onCompletion(nil, error)
                }
            }
        }
    }
    
    func getWorkPackagesByProjectId(projectId: NSNumber, instanceId: String, onCompletion: RemoteWorkpackagesResponse) {
        guard let instances = Instance.MR_findByAttribute("id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = [
                "Authorization": "\(instance.auth)",
                "Accept": "application/hal+json"
            ]
            
            let url = "\(instance.address!)/api/v3/projects/\(projectId)/work_packages?offset=1,"
            
            Alamofire.request(.GET, url, headers: headers).validate().responseString { response in
                var workpackages = [WorkPackage]()
                switch response.result {
                case .Success:
                    guard let responseValue = response.result.value else {
                        onCompletion(workpackages, nil)
                        return
                    }
                    
                    guard let dataFromResponse = responseValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                        onCompletion(workpackages, nil)
                        return
                    }
                    
                    let json = JSON(data: dataFromResponse)
                    print("Workpackages successfully received - \(json)")
                    WorkPackage.buildWorkpackages(projectId, json: json)
                    workpackages = WorkPackage.MR_findAll() as! [WorkPackage]
                    onCompletion(workpackages, nil)
                case .Failure(let error):
                    print(error)
                    onCompletion(nil, error)
                }
            }
        }
    }
    
    private func getBasicAuth(apiKey: String) -> String {
        let loginString = NSString(format: "apikey:%@", apiKey)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        return "Basic \(loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))"
    }
}