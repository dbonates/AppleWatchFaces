//
//  FaceBackgroundSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class FaceBackgroundSettingsTableViewCell: WatchSettingsSelectableTableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var faceBackgroundSelectionCollectionView: UICollectionView!
    
    //var selectedCellIndex:Int?
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
    
        let currentSetting = SettingsViewController.currentClockSetting.faceBackgroundType
        if let typeIndex = FaceBackgroundTypes.userSelectableValues.firstIndex(of: currentSetting) {
            let indexPath = IndexPath.init(row: typeIndex, section: 0)

            //scroll and set native selection
            faceBackgroundSelectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.right)

            //stupid hack to force selection after scroll
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                self.setCellSelection(indexPath: indexPath)
            })
        }
    }
    
    func setCellSelection( indexPath: IndexPath ) {
        //select new one
        if let settingsCell = faceBackgroundSelectionCollectionView.cellForItem(at: indexPath) as? FaceBackgroundSettingCollectionViewCell {
            if let scene = settingsCell.skView.scene, let selectedNode = scene.childNode(withName: "selectedNode") {
                //TODO: animate this
                selectedNode.isHidden = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let settingType = FaceBackgroundTypes.userSelectableValues[indexPath.row]
        debugPrint("selected cell faceBackgroundTypes: " + settingType.rawValue)
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        //update the value
        SettingsViewController.currentClockSetting.faceBackgroundType = settingType
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                        userInfo:["cellId": self.cellId , "settingType":"faceBackgroundType"])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let settingType = FaceBackgroundTypes.userSelectableValues[indexPath.row]
        debugPrint("deSelected cell faceBackgroundTypes: " + settingType.rawValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FaceBackgroundTypes.userSelectableValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsHandCell", for: indexPath) as! FaceBackgroundSettingCollectionViewCell
        
        if cell.skView.scene == nil  {
            //first run. create a new scene
            let previewScene = SKScene.init()
            previewScene.scaleMode = .aspectFill
            
            // Present the scene
            cell.skView.presentScene(previewScene)
            cell.skView.delegate = cell
        }
        
        cell.faceBackgroundType = FaceBackgroundTypes.userSelectableValues[indexPath.row]
        cell.redrawScene()
        
        return cell
    }
    
    
}

