//
//  Vision.swift
//  Alchemy
//
//  Created by Vincent Herrin on 9/30/15.
//  Copyright © 2015 MIL. All rights reserved.
//

import Foundation
import WatsonCore

// TODO: Need to move this into the correct location

// this will be be moved to the correct file once I get things up and running
// API Contract
public protocol VisionService
{
    init(apiKey: String)
    
    func urlGetRankedImageKeywords(url: String, outputMode: AlchemyConstants.OutputMode, forceShowAll: Bool, knowledgeGraph: Int8, callback: (RankedImageKeywordsModel!, ResultStatusModel!)->())
    
    // I will add this back in once it url is finished
    //func imageGetRankedImageKeywords(base64Image: String, mode: Constants.OutputMode)
}

public class VisionImpl: AlchemyCoreImpl, VisionService {
    
    private let TAG = "[VISION] "
    
    /// your private api key
    let _apiKey : String
    
    /**
    Initialization of the main Alchemy service class
    
    - parameter apiKey: your private api key
    
    */
    public required init(apiKey: String) {
        
        _apiKey = apiKey
        //utils = NetworkUtils(type: ServiceType.Alchemy)
        super.init(apiKey: apiKey)
    }
    
    
    /**
    The URLGetRankedImageKeywords call is used to tag an image in a given web page. AlchemyAPI will download the requested URL, extracting the primary image from the HTML document structure and perform image tagging.
    
    - parameter url:             http url (must be uri-argument encoded)            REQUIRED
    - parameter outputMode:      Desired API output format (optional parameter)
    - parameter forceShowAll:    Includes lower confidence tags
    - parameter knowledgeGraph:  Possible values: 0 (default), 1
    - parameter callback:        Callback with  and RankedImageKeywordsModel and ResultStatusModel
    */
    public func urlGetRankedImageKeywords(url: String, outputMode: AlchemyConstants.OutputMode = AlchemyConstants.OutputMode.XML, forceShowAll: Bool = false, knowledgeGraph: Int8 = 0, callback:(RankedImageKeywordsModel!, ResultStatusModel!)->()) {
        
        let paramsData: NSData = NSData()
        
        var params = buildCoreURL(url)
        
        if(outputMode.rawValue != AlchemyConstants.OutputMode.XML.rawValue) {
            params = addOrUpdateQueryStringParameter(params, key: AlchemyConstants.VisionURI.OutputMode.rawValue, value: outputMode.rawValue)
        }
        
        if(forceShowAll == true) {
            params = addOrUpdateQueryStringParameter(params, key: AlchemyConstants.VisionURI.ForceShowAll.rawValue, value: forceShowAll.hashValue.description)
        }
        
        if(knowledgeGraph > 0) {
            params = addOrUpdateQueryStringParameter(params, key: AlchemyConstants.VisionURI.KnowledgeGraph.rawValue, value: knowledgeGraph.description)
        }
        
        self.analyze(AlchemyConstants.Base + AlchemyConstants.VisionPrefixURL + AlchemyConstants.ImageTagging.URLGetRankedImageKeywords.rawValue + params, body: paramsData, callback: {response, error in
            guard response.status == AlchemyConstants.Status.OK.rawValue else {
                callback(nil,response)
                return
            }
            callback(RankedImageKeywordsModel.getRankedImageKeywordsModel(response.rawData),response)
        })
    }
    
    
    /**
    Builds the specific URL for the given caller and appends the needed API key
    
    - parameter url: The specific URL for the given Alchemy call
    - returns: the appended core URL.  Please note that additional parameters will be be added to this URL in the specific caller
    */
    private func buildCoreURL(url: String)->String {
        var coreURL = addOrUpdateQueryStringParameter("",key: AlchemyConstants.WatsonURI.APIKey.rawValue, value: _apiKey)
        coreURL = addOrUpdateQueryStringParameter(coreURL, key: AlchemyConstants.WatsonURI.URL.rawValue, value: url)
        return coreURL
    }
}
