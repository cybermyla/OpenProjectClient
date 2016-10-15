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
    fileprivate init() {}
    
    typealias RemoteRootResponse = (Instance?, NSError?) -> Void
    
    typealias RemoteProjectsResponse = ([Project]?, NSError?) -> Void
    
    typealias RemoteWorkpackagesResponse = ([WorkPackage]?, NSError?) -> Void
    
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
            case .success(let value):
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
            /*
            let headers = [
                "Authorization": "\(instance.auth)",
                "Accept": "application/json"
            ]
            */
            let url = "\(instance.address!)/api/v2/projects.json?key=\(instance.apikey!)"
            
            //Alamofire.request(.GET, url, headers: headers).validate().responseString { response in
            Alamofire.request(url).validate().responseString { response in
                var projects = [Project]()
                switch response.result {
                case .success(let value):
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
            
            let headers = [
                "Authorization": "\(instance.auth!)",
                "Accept": "application/hal+json"
            ]
            
            let url = "\(instance.address!)/api/v3/projects/\(projectId)/work_packages?offset=1"
            
            Alamofire.request(url, headers: headers).validate().responseString { response in
                var workpackages = [WorkPackage]()
                switch response.result {
                case .success(let value):
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
                    WorkPackage.buildWorkpackages(projectId, json: json)
                    workpackages = WorkPackage.mr_findAll() as! [WorkPackage]
                    onCompletion(workpackages, nil)
                case .failure(let error):
                    print(error)
                    onCompletion(nil, error as NSError?)
                }
            }
        }
    }
    
    fileprivate func getBasicAuth(_ apiKey: String) -> String {
        let loginString = NSString(format: "apikey:%@", apiKey)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        return "Basic \(loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))"
    }
}
