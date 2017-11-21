//
//  Exporter.swift
//  BuildLearningModel
//
//  Created by NGUYEN, LONG on 11/20/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation

class Exporter: NSObject {
    // Default XML template
    var xmls = ["<annotation>\n", "\t<folder>VOC2017</folder>\n", "\t<filename>000026.jpg</filename>\n", "\t<source>\n", "\t\t<database>The VOC2017 Database</database>\n", "\t\t<annotation>PASCAL VOC2017</annotation>\n", "\t\t<image>flickr</image>\n", "\t\t<flickrid>000000</flickrid>\n", "\t</source>\n", "\t<owner>\n", "\t\t<flickrid>oishi</flickrid>\n", "\t\t<name>?</name>\n", "\t</owner>\n", "\t<size>\n", "\t\t<width>500</width>\n", "\t\t<height>333</height>\n", "\t\t<depth>3</depth>\n", "\t</size>\n", "\t<segmented>0</segmented>\n"]
    
    
    func exportToVOC(imageDirectoryPath: String) {
        let imageName = "timestamp_hand_right_100_200_150_250_300_300.jpeg"
        
        // enumberate the content in given imageDirectoryPath
        saveToVOCXML(imageName)
        
    }
    
    
    func saveToVOCXML(_ imageName: String) {
        // extract the values base on image file name.
        let values = imageName.components(separatedBy: "_")
//        let timestamp = values[0]
        let tag = values[1]
        let subTag = values[2]
        let xmin = values[3]
        let ymin = values[4]
        let xmax = values[5]
        let ymax = values[6]
        let width = values[7]
        let height = values[8]
        
        xmls[2] = "\t<filename>"+imageName+"</filename>\n" // EX ABC.jpeg
        xmls.append("\t<object>\n")
        xmls.append("\t\t<name>"+tag+"</name>\n") // EX: HAND
        xmls.append("\t\t<pose>"+subTag+"</pose>\n") // EX : LEFT / RIGHT
        xmls.append("\t\t<truncated>0</truncated>\n")
        xmls.append("\t\t<difficult>0</difficult>\n")
        xmls.append("\t\t<bndbox>\n")
        xmls.append("\t\t\t<xmin>"+xmin+"</xmin>\n")
        xmls.append("\t\t\t<ymin>"+ymin+"</ymin>\n")
        xmls.append("\t\t\t<xmax>"+xmax+"</xmax>\n")
        xmls.append("\t\t\t<ymax>"+ymax+"</ymax>\n")
        xmls.append("\t\t</bndbox>\n")
        xmls.append("\t</object>\n")
        xmls[14] = "\t\t<width>"+width+"</width>\n"
        xmls[15] = "\t\t<height>"+height+"</height>\n"
        
        xmls.append("</annotation>\n")
        // save as XML
        
    }
    
}
