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

    var manager: SessionManager?
    
    var _getProjects: DataRequest?
    var _getWorkPackages: DataRequest?
    var _postWorkPackagesForms: DataRequest?
    var _createOrUpdateWorkpackage: DataRequest?
    var _getAvailableAssignees: DataRequest?
    var _getAvailableResponsibles: DataRequest?
    var _getActivities: DataRequest?
    var _getUser: DataRequest?
    var _getWatchers: DataRequest?
    var _getTypes: DataRequest?
    var _getPriorities: DataRequest?
    var _getStatuses: DataRequest?
    var _sendActivityComment: DataRequest?
    var _removeWatcher: DataRequest?
    var _getAvailableWatchers: DataRequest?
    
    static let sharedInstance : OpenProjectAPI = OpenProjectAPI()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        manager = SessionManager(configuration: configuration)
    }
    
    typealias RemoteJSONResponse = (JSON, NSError?) -> Void
    typealias RemoteBoolResponse = (Bool, NSError?) -> Void
    
    func getInstance(_ address: String, apikey: String, onCompletion: @escaping RemoteJSONResponse) {
        
        let auth = getBasicAuth(apikey)
        
        let headers = [
            "Authorization": "\(auth)",
            "Accept": "application/hal+json"
        ]
        let url = "\(address)/api/v3"
        
        manager!.request(url, encoding: URLEncoding.default, headers: headers).validate().responseString { response in
            
            switch response.result {
            case .success( _):
                guard let responseValue = response.result.value else {
                    onCompletion(nil, nil)
                    return
                }
                
                guard let dataFromResponse = responseValue.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                    onCompletion(nil, nil)
                    return
                }
                
                let json = JSON(data: dataFromResponse)
                
                Instance.buildInstance(address, api: apikey, auth: auth, json: json)
                print("Root successfully received")
                print("\(response)")
                onCompletion(json, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error as NSError?)
            }
        }
    }
    
    func getProjects(_ instanceId: String, onCompletion: @escaping RemoteBoolResponse) {
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]

            let url = "\(instance.address!)/api/v2/projects.json?key=\(instance.apikey!)"
            
            if let existinGetProjects = _getProjects {
                existinGetProjects.cancel()
                print("\(Date()) Existing get projects request has been canceled")
            }
            print("\(Date()) Sending get projects request \(url)")
            self._getProjects = manager!.request(url).validate().responseString { response in
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
                    print("\(Date()) Get projects response successfuly received")
                    let json = JSON(data: dataFromResponse)
                    Project.buildProjects(json)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get projects request failed \(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        }
    }
    
    func getWorkPackagesByProjectId(_ projectId: NSNumber, offset: Int, pageSize: Int, truncate: Bool, instanceId: String, onCompletion: @escaping RemoteBoolResponse) {
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let filters = WPFilter.getWPFilter(projectId, instanceId: instanceId)
            
            let url = "\(instance.address!)/api/v3/projects/\(projectId)/work_packages?offset=\(offset)&pageSize=\(pageSize)\(filters)"
            
            if let existinGetProjects = _getWorkPackages {
                existinGetProjects.cancel()
                print("\(Date()) Existing get workpackages request has been canceled")
            }
            print("\(Date()) Sending get workpackages request \(url)")
            
            _getWorkPackages = manager!.request(url, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get workpackages response successfully received")
                    WorkPackage.buildWorkpackages(projectId, instanceId: instanceId, truncate: truncate, json: json)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Workpackages request failed \(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        }
    }

    func getWorkpackagesForms(wpId: Int32?, payload: String?, onCompletion: @escaping RemoteJSONResponse) {

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
            
            if let existingRequest = _postWorkPackagesForms {
                existingRequest.cancel()
                print("\(Date()) Existing post workpackage form validate/empty request has been canceled")
            }
            
            
            if payload != nil {
                print("\(Date()) Sending validate workpackage forms request \(url)")
                _postWorkPackagesForms = manager!.request(url, method: .post, parameters: paramsFromJSON(json: payload!), encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
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
                        print("\(Date()) Received workpackage forms request - validate")
                        onCompletion(json, nil)
                    case .failure(let error):
                        print("\(Date()) Request workpackage forms failed - validate\n\(error)\n\(payload)")
                        onCompletion(false, error as NSError?)
                    }
                }
            } else {
                print("\(Date()) Sending post workpackage forms request - get form \(url)")
                _postWorkPackagesForms = manager!.request(url, method:.post, headers: headers).validate().responseString { response in
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
                        print("\(Date()) Received post workpackage forms response - get form")
                        onCompletion(json, nil)
                    case .failure(let error):
                        print("\(Date()) Request post workpackage forms failed - get form\n\(error)")
                        onCompletion(false, error as NSError?)
                    }
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func verifyWorkpackageFormPayload(wpId: Int32?, payload: String, onCompletion: @escaping RemoteJSONResponse) {
        
        getWorkpackagesForms(wpId: nil, payload: payload, onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                onCompletion(json, nil)
            }
        })
    }
    
    func createOrUpdateWorkpackage(wpId: Int32?, payload: String, onCompletion: @escaping RemoteJSONResponse) {
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
            
            if let existingRequest = _createOrUpdateWorkpackage {
                existingRequest.cancel()
                print("\(Date()) Existing create or update workpackage request has been canceled")
            }
            print("\(Date()) Sending \(operationName) workpackage request - \(url)")
            
            _createOrUpdateWorkpackage = manager!.request(url, method: method, parameters: paramsFromJSON(json: payload), encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
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
                    print("\(Date()) \(operationName) workpackage response successfully received")
                    onCompletion(json, nil)
                case .failure(let error):
                    print("\(Date()) \(operationName) workpackage response failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getWorkpackagesCreateFormsPayload(onCompletion: @escaping RemoteBoolResponse) {
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
    
    func getWorkpackagesUpdateFormsPayload(wpId: Int32, onCompletion: @escaping RemoteBoolResponse) {
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
    
    func getPrioritiesStatusesTypes(onCompletion: @escaping RemoteBoolResponse) {
        
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let projectId = Int(defaults.string(forKey: "ProjectId")!) else {
            return
        }
        
        getWorkpackagesForms(wpId: nil, payload: nil, onCompletion: {(json:JSON, error:NSError?) in
            if let issue = error {
                onCompletion(false, issue as NSError?)
            } else {
                Priority.buildPriorities(Int32(projectId), instanceId: instanceId!, json: json)
                let _ = Type.buildTypes(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let _ = Status.buildStatuses(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                let _ = Version.buildVersions(NSNumber(value:projectId), instanceId: instanceId!, json: json)
                onCompletion(true, nil)
            }
        })
    }
    
    func getAvailableAssignees(onCompletion: @escaping RemoteBoolResponse) {
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
            
            if let existingRequest = _getAvailableAssignees {
                existingRequest.cancel()
                print("\(Date()) Existing get available assignees request has been canceled")
            }
            print("\(Date()) Sending get available assignees request - \(url)")
            
            manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) get available assignees request successfuly received")
                    Assignee.buildAssignees(NSNumber(value: projectId), instanceId:instanceId!, json: json, isAssignee: true)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) get available assignees request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getAvailableResponsibles(onCompletion: @escaping RemoteBoolResponse) {
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
            
            if let existingRequest = _getAvailableResponsibles {
                existingRequest.cancel()
                print("\(Date()) - Existing get available responsibles request has been canceled")
            }
            print("\(Date()) - Sending get available responsibles request - \(url)")
            
            manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) - Get available responsibles response successfuly received")
                    Assignee.buildAssignees(NSNumber(value: projectId), instanceId:instanceId!, json: json, isAssignee: false)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) - Get available responsibles request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getActivities(href: String, onCompletion: @escaping RemoteBoolResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(href)"
            
            if let existingRequest = _getActivities {
                existingRequest.cancel()
                print("\(Date()) Existing get activities request has been canceled")
            }
            print("\(Date()) Sending get activities request - \(url)")
            
            _getActivities = manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get activities response successfuly received")
                    WorkPackageActivity.buildWPActivities(json: json)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get activities request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }

    }
    
    func getUser(href: String, onCompletion: @escaping RemoteBoolResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(href)"
            
            if let existingRequest = _getUser {
                existingRequest.cancel()
                print("\(Date()) Existing get user request has been canceled")
            }
            print("\(Date()) Sending get user request - \(url)")
            
            _getUser = manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get user response successfuly received")
                    OpUser.buildOpUser(json: json, saveToContext: true)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get user request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getWatchers(href: String, onCompletion: @escaping RemoteJSONResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(href)"
            
            if let existingRequest = _getWatchers {
                existingRequest.cancel()
                print("\(Date()) Existing get watchers request has been canceled")
            }
            print("\(Date()) Sending get watchers request - \(url)")
            
            _getWatchers = manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get watchers response successfuly received")
                    onCompletion(json, nil)
                case .failure(let error):
                    print("\(Date()) Get watchers request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getPriorities(onCompletion: @escaping RemoteBoolResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        let projectId = defaults.string(forKey: "ProjectId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        guard let intProjectId = Int32(projectId!) else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(instance.prioritiesHref!)"
            
            if let existingRequest = _getPriorities {
                existingRequest.cancel()
                print("\(Date()) Existing get priorities request has been canceled")
            }
            print("\(Date()) Sending get priorities request - \(url)")
            
            _getPriorities = manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get priorities response successfuly received")
                    Priority.buildPriorities(intProjectId, instanceId: instanceId!, json: json)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get priorities request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getStatuses(onCompletion: @escaping RemoteBoolResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        let projectId = defaults.string(forKey: "ProjectId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        guard let intProjectId = Int32(projectId!) else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(instance.statusesHref!)"
            
            if let existingRequest = _getStatuses {
                existingRequest.cancel()
                print("\(Date()) Existing get statuses request has been canceled")
            }
            print("\(Date()) Sending get statuses request - \(url)")
            
            _getStatuses = manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get statuses response successfuly received")
                    Type.buildTypes(NSNumber(value: intProjectId), instanceId: instanceId!, json: json)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get statuses request failed\n\(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getTypes(onCompletion: @escaping RemoteBoolResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        let projectId = defaults.string(forKey: "ProjectId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        guard let intProjectId = Int32(projectId!) else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)\(instance.typesHref!)"
            
            if let existingRequest = _getTypes {
                existingRequest.cancel()
                print("\(Date()) Existing get types request has been canceled")
            }
            print("\(Date()) Sending get types request - \(url)")
            
            _getTypes = manager!.request(url, method:.get, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Get types response successfuly received")
                    Status.buildStatuses(NSNumber(value: intProjectId), instanceId: instanceId!, json: json)
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get types request failed\n\(error)")
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
            
            if let existingRequest = _sendActivityComment {
                existingRequest.cancel()
                print("\(Date()) Existing send activity comment request has been canceled")
            }
            print("\(Date()) Sending activity comment request - \(url)")
            
            _sendActivityComment = manager!.request(url, method: .post, parameters: paramsFromJSON(json: payload), encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Send activity comment response successfuly received")
                    onCompletion(json, nil)
                case .failure(let error):
                    print("\(Date()) Send activity comment request failed \(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func removeWorkPackageWatcher(watcherId: Int32, workPackageId: Int32, onCompletion: @escaping RemoteJSONResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)
            
            let url = "\(instance.address!)/api/v3/work_packages/\(workPackageId)/watchers/\(watcherId)"
            
            if let existingRequest = _removeWatcher {
                existingRequest.cancel()
                print("\(Date()) Existing remove watcher request has been canceled")
            }
            print("\(Date()) Sending remove watcher request - \(url)")
            
            _removeWatcher = manager!.request(url, method: .delete, headers: headers).validate().responseString { response in
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
                    print("\(Date()) Remove watcher response successfuly received")
                    onCompletion(json, nil)
                case .failure(let error):
                    print("\(Date()) Remove watcher request failed \(error)")
                    onCompletion(false, error as NSError?)
                }
            }
        } else {
            onCompletion(false, nil)
        }
    }
    
    func getAvailableWatchers(workPackageId: Int32, onCompletion: @escaping RemoteBoolResponse) {
        let defaults = UserDefaults.standard
        let instanceId = defaults.string(forKey: "InstanceId")
        
        guard let instances = Instance.mr_find(byAttribute: "id", withValue: instanceId) as? [Instance] else {
            return
        }
        
        if instances.count > 0 {
            let instance = instances[0]
            
            let headers = getHeaders(auth: instance.auth!)

            let url = "\(instance.address!)/api/v3/work_packages/\(workPackageId)/available_watchers"
            
            if let existingRequest = _removeWatcher {
                existingRequest.cancel()
                print("\(Date()) Existing get available watchers request has been canceled")
            }
            print("\(Date()) Sending get available watchers request - \(url)")
            
            _getAvailableWatchers = manager!.request(url, method: .get, headers: headers).validate().responseString { response in
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
                    OpUser.buildOpUsers(json: json)
                    print("\(Date()) Get available watchers response successfuly received")
                    onCompletion(true, nil)
                case .failure(let error):
                    print("\(Date()) Get available watchers request failed \(error)")
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
