//
//  DocumentManager.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/31/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

enum ImageFormat {
    case jpeg
    case png
    
    var stringValue : String {
        if self == .jpeg {
            return "jpeg"
        }
        if self == .png {
            return "png"
        }
        return "nil"
    }
}

extension String {
    var removeSpaces : String {
        return self.replacingOccurrences(of: " ", with: "_")
    }
    
    var removeUnderscore : String {
        return self.replacingOccurrences(of: "_", with: " ")
    }
}

//Reading and writing tasks should use appropriate queue to prevent conflict.
//private let readingQueue = DispatchQueue(label: "com.hk.concurrentQueue.readFile", attributes: .concurrent) //Concurent queue
//private let writingQueue = DispatchQueue(label: "com.hk.serialQueue.writeFile") //Serial queue
//private weak var mainQueue = DispatchQueue.main

class ExtendQueue : OperationQueue {
    override func addOperation(_ block: @escaping () -> Void) {
        log("queue >>> Current tasks in \(self.name ?? "Queue") is \(self.operationCount)")
        log("queue >>> \(self.name ?? "Queue") Gonna execute new task")
        super.addOperation(block)
    }
}

private let readingQueue : ExtendQueue = {
    let queue = ExtendQueue()
    queue.name = "ReadingQueue"
    return queue
}()
private let writingQueue : ExtendQueue = {
    let queue = ExtendQueue()
    queue.name = "WritingQueue"
    queue.maxConcurrentOperationCount = 1
    return queue
}()

private weak var mainQueue : OperationQueue! = OperationQueue.main


class Workspace {
    static let shared = Workspace()
    
    init() {
        DocumentManager.shared.createDirIfNeeded(self.dirPath)
    }
    
    var dirPath : URL {
        return DocumentManager.shared.projectsDirPath
    }
    
    func loadProjects(completion:(([Project])->Void)?) {
        let loading = {
            var projects = [Project]()
            do {
                let urls = DocumentManager.shared.getURLContents(self.dirPath)
                for (_, url) in urls.enumerated() {
                    if let isDir = try url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory, isDir {
                        let project = Project(projectName:url.lastPathComponent.removeUnderscore)
                        projects.append(project)
                    }
                }
            } catch {
                log("load project >>> Cannot read dir properties")
                mainQueue.addOperation {
                    completion?([])
                }
                return
            }
            
            mainQueue.addOperation {
                completion?(projects)
            }
        }
        OperationQueue.current == readingQueue ? loading() : readingQueue.addOperation(loading)
    }
}

class Project {
    var projectName : String!
    var tags : [Tag]!
    
    var dirPath : URL {
        return DocumentManager.shared.getDirPathForProject(projectName)
    }
    
    init(projectName: String) {
        self.projectName = projectName
        
        DocumentManager.shared.createDirIfNeeded(dirPath)
    }
    
    func loadTags(andFile: Bool = false, andImage: Bool = false, completion: ((Bool)->Void)? = nil) {
        
        let loading = {
            do {
                self.tags = [Tag]()
                let urls = DocumentManager.shared.getURLContents(self.dirPath)
                for (index,url) in urls.enumerated() {
                    if let isDirectory = try  url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory, isDirectory {
                        log("load project >>> Add #\(index) tag \(url.lastPathComponent.removeUnderscore)")
                        let tag = Tag(tagName: url.lastPathComponent.removeUnderscore, project: self)
                        self.tags.append(tag)
                        
                        tag.loadFiles(readImage: andFile, nil)
                    }
                }
                log("load project >>> Found \(urls.count), added \(self.tags.count) tags")
                
            } catch {
                log("load project >>> Exception, cannot load project")
                mainQueue.addOperation { completion?(false) }
                return
            }
            
            log("load project >>> Completed loading, then invoke callback")
            mainQueue.addOperation { completion?(true) }
        }
        OperationQueue.current == readingQueue ? loading() : readingQueue.addOperation(loading)
    }
    
    func createTag(_ name: String) -> Tag {
        return Tag(tagName: name, project: self)
    }
}

class Tag {
    weak var project : Project!
    var tagName : String
    var files : [RawFile]!
    
    init(tagName: String, project: Project) {
        self.project = project
        self.tagName = tagName
        
        DocumentManager.shared.createDirIfNeeded(self.dirPath)
    }
    
    var dirPath : URL {
//        return DocumentManager.shared.getDirPathForTag(tagName, in: project!.projectName)
        return Tag.getDirPath(tagName, projectName: project!.projectName)
    }
    
    func loadFiles(readImage: Bool = false, _ completion: ((Bool)->Void)? = nil) {
        let loading = {
            do {
                self.files = [RawFile]()
                let urls = DocumentManager.shared.getURLContents(self.dirPath, dirOnly: false)
                for (index,url) in urls.enumerated() {
                    log("load file >>> Add #\(index) file \(url)")
                    let file = RawFile(image: nil, name: url.lastPathComponent, tag: self)
                    self.files.append(file)
                }
                log("load file >>> Found \(urls.count), added \(self.files.count) news")
            } catch {
                log("load file >>> Exception, cannot load files")
                mainQueue.addOperation { completion?(false) }
                return
            }
            
            log("load file >>> Completed loading, then invoke callback")
            mainQueue.addOperation { completion?(true) }
        }
        
        OperationQueue.current == readingQueue ? loading() : readingQueue.addOperation(loading)
    }
    
    private func createRawFile(_ image: UIImage, name: String) -> RawFile {
        return RawFile(image: image, name: name, tag: self)
    }
    
    func saveFile(_ image: UIImage, name: String) -> RawFile {
        let format  = ImageFormat.jpeg
        let fileName = "\(name).\(format)"
        let file = createRawFile(image, name: fileName)
        files.append(file)
        
        //Write to document
        DocumentManager.shared.saveImage(image, path: file.dirPath, format: .jpeg)
        
        return file
    }
    
    
    func rename(to newName: String, completion: ((Bool)->Void)? = nil) {
        DocumentManager.shared.rename(dirPath, newName: newName) { (success) in
            
            if success { self.tagName = newName }
            mainQueue.addOperation { completion?(success) }
        }
        
    }
    
    static func getDirPath(_ tagName: String, projectName: String) -> URL {
        return DocumentManager.shared.getDirPathForTag(tagName, in: projectName)
    }
}

class RawFile {
    weak var tag : Tag!
    var fileName : String
    var image : UIImage!
    var dirPath : URL {
        return tag.dirPath.appendingPathComponent(fileName)
    }
    
    init(image: UIImage!, name: String, tag: Tag) {
        self.image = image
        self.tag = tag
        self.fileName = name
    }
    
    func loadImage(_ completion: ((Bool)->Void)? = nil) {
    }
}

class DocumentManager {
    
    static let shared = DocumentManager()
    
    lazy var projectsDirPath : URL = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return URL(fileURLWithPath: documentsPath!, isDirectory: true).appendingPathComponent("workspace", isDirectory: true)
    }()
    
    func getDirPathForProject(_ projectName: String) -> URL {
        return projectsDirPath.appendingPathComponent(projectName.removeSpaces, isDirectory: true)
    }
    
    func getDirPathForTag(_ tagName: String,in projectName: String) -> URL {
        return getDirPathForProject(projectName).appendingPathComponent(tagName.removeSpaces, isDirectory: true)
    }
    
    func checkExisting(_ dirPath: URL) -> Bool {
        var isDir : ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: dirPath.relativePath, isDirectory: &isDir)
        if isExist && isDir.boolValue == true {
            log("dm >>> Found dir \(dirPath.relativePath)")
            return true
        } else {
            log("dm >>> Not found dir \(dirPath.relativePath)")
            return false
        }
    }
    
    func createDirIfNeeded(_ dirPath: URL) {
        guard checkExisting(dirPath) == false else { return }
        do {
            try FileManager.default.createDirectory(atPath: dirPath.relativePath, withIntermediateDirectories: true, attributes: [:])
            log("dm >>> Creare dir \(dirPath.relativePath)")
        } catch {
            log("dm >>> Error when create dir \(dirPath.relativePath)")
        }
    }
    
    
    
    func rename(_ dirPath: URL, newName: String, completion: ((Bool)->Void)? = nil) {
        guard dirPath.isFileURL else { log("url not valid with \(dirPath)"); return }
        
        let newDirPath = URL(fileURLWithPath: dirPath.relativePath).deletingLastPathComponent().appendingPathComponent(newName, isDirectory: true)
        
        writingQueue.addOperation {
            do {
                try FileManager.default.moveItem(at: dirPath, to: newDirPath)
//                try FileManager.default.removeItem(at: dirPath)
            } catch {
                log("dm >>> rename is failed")
                completion?(false)
                return
            }
            log("dm >>> rename success to \(newDirPath.relativePath)")
            completion?(true)
        }
    }
    ///dirOnly = true mean get dir URls, otherwise get file Urls
    func getURLContents(_ dirPath: URL, dirOnly: Bool = true) -> [URL] {
        
        do {
            let properties : [URLResourceKey]? = dirOnly ? [URLResourceKey.isDirectoryKey] : nil
            let urls = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: properties, options: .skipsHiddenFiles)
            return urls
        } catch {
            log("dm >>> Error when count files / dirs")
        }
        return []
    }
    
    func saveImage(_ image: UIImage, path: URL, format: ImageFormat = .jpeg) {
        
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        var data : Data!
        
        if format == .jpeg {
            data = UIImageJPEGRepresentation(image, 1)
        } else if format == .png {
            data = UIImagePNGRepresentation(image)
        }
        
        do {try data.write(to: path, options: .atomicWrite) }
        catch {
            log("dm >>> Exception while saving file")
        }
    }
    
    
}

