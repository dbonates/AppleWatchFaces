//
//  WatchSettingsTableViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/29/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import Foundation

//used in the subclassed cells to override calling selection
class WatchSettingsSelectableTableViewCell:UITableViewCell {
    
    var cellId: String = ""
    
    func chooseSetting( animated: Bool ) {
        debugPrint("** generic chooseSetting called, not overridden **")
    }
}

class WatchSettingsTableViewController: UITableViewController {
    
    static let settingsTableSectionReloadNotificationName = Notification.Name("settingsTableSectionReload")
    
    //current selected group
    var currentGroupIndex = 0
    
    //this defines the order and information in the settings table,
    // NOTE: overriden based on Default options in setSectionDataForOptions() based on complexity level
    var sectionsData = [
        [
            ["title":"Title",                       "category":"normal",      "rowHeight":"66.0", "cellID":"titleSettingsTableViewCellID"],
            ["title":"Color Theme",                 "category":"normal",      "rowHeight":"130.0", "cellID":"colorThemeSettingsTableViewCellID"],
            ["title":"Items Theme",                 "category":"normal",      "rowHeight":"130.0","cellID":"decoratorThemeSettingsTableViewCellID"],
            ["title":"Background Transparency",      "category":"advanced",      "rowHeight":"144.0","cellID":"mainAlphaTableViewCellID"],
            ["title":"Hand Transparency",           "category":"advanced",    "rowHeight":"144.0","cellID":"handsAlphaTableViewCellID"],
            ["title":"Decorator Transparency",       "category":"advanced",      "rowHeight":"144.0","cellID":"ringsAlphaTableViewCellID"]
        ],
        [
            ["title":"Background Type",             "category":"normal",      "rowHeight":"80.0","cellID":"faceBackgroundTypeTableViewCell"],
            ["title":"Bottom Layer Texture",        "category":"normal",      "rowHeight":"100.0","cellID":"mainBackgroundColorsTableViewCell"],
            ["title":"Top Layer Texture",           "category":"normal",      "rowHeight":"100.0","cellID":"faceBackgroundColorsTableViewCell"],
            ["title":"Overlay Type",                "category":"advanced",    "rowHeight":"80.0","cellID":"faceForegroundTypeTableViewCell"],
            ["title":"Overlay Color",               "category":"advanced",    "rowHeight":"100.0","cellID":"faceOverlayColorsTableViewCell"],
            ["title":"Overlay Options",              "category":"advanced",    "rowHeight":"184.0","cellID":"faceForegroundOptionsSettingsTableViewCellID"]
        ],
        [
            
            ["title":"Second Hand",                 "category":"normal",      "rowHeight":"100.0","cellID":"secondHandSettingsTableViewCell"],
            ["title":"Second Hand Color",           "category":"normal",      "rowHeight":"100.0","cellID":"secondHandColorsTableViewCell"],
            
            ["title":"Minute Hand",                 "category":"normal",      "rowHeight":"100.0","cellID":"minuteHandSettingsTableViewCell"],
            ["title":"Minute Hand Color",           "category":"normal",      "rowHeight":"100.0","cellID":"minuteHandColorTableViewCell"],
            
            ["title":"Hour Hand",                   "category":"normal",      "rowHeight":"100.0","cellID":"hourHandSettingsTableViewCell"],
            ["title":"Hour Hand Color",             "category":"normal",      "rowHeight":"100.0","cellID":"hourHandColorTableViewCell"],
            
            ["title":"Second Hand Animation",       "category":"advanced",    "rowHeight":"130.0","cellID":"secondhandAnimationSettingsTableViewCellID"],
            ["title":"Minute Hand Animation",       "category":"advanced",    "rowHeight":"130.0","cellID":"minutehandAnimationSettingsTableViewCellID"],
            
            ["title":"Hand Display",                "category":"advanced",    "rowHeight":"66.0","cellID":"handsOptionsSettingsTableViewCellID"],
            ["title":"Hand Outline Color",          "category":"advanced",    "rowHeight":"100.0","cellID":"handOutlineColorTableViewCell"],
            ["title":"Hand Effects",                "category":"advanced",    "rowHeight":"144.0","cellID":"handsEffectsTableViewCellID"]
        ],
        [
            ["title":"Indicator Path",             "category":"path-render", "rowHeight":"100.0","cellID":"ringShapeSettingsTableViewCellID"],
            ["title":"Indicator Parts",             "category":"advanced",    "rowHeight":"66.0","cellID":"ringEditorTableViewCellID"],
            ["title":"Indicators Main Color",       "category":"normal",      "rowHeight":"100.0","cellID":"ringMainColorsTableViewCell"],
            ["title":"Indicators Secondary Color",  "category":"normal",      "rowHeight":"100.0","cellID":"ringSecondaryColorsTableViewCell"],
            ["title":"Indicators Highlight Color",  "category":"normal",      "rowHeight":"100.0","cellID":"ringThirdColorsTableViewCell"]
            
        ]
    ]
    
    func valueForHeader( section: Int) -> String {
        var settingText = ""
        
        //base this off of the cellID so the data can be dynamic / grouped
        let cellID = sectionsData[currentGroupIndex][section]["cellID"]
        
        switch cellID {
        
        case "titleSettingsTableViewCellID":
            settingText = SettingsViewController.currentClockSetting.title
        case "colorThemeSettingsTableViewCellID":
            settingText = SettingsViewController.currentClockSetting.themeTitle
        case "decoratorThemeSettingsTableViewCellID":
            settingText = SettingsViewController.currentClockSetting.decoratorThemeTitle
        case "mainAlphaTableViewCellID":
            settingText = SettingsViewController.currentClockSetting.clockFaceMaterialAlpha.description
            + " " + SettingsViewController.currentClockSetting.clockCasingMaterialAlpha.description
            + " " + SettingsViewController.currentClockSetting.clockForegroundMaterialAlpha.description
        case "faceBackgroundTypeTableViewCell":
            settingText = FaceBackgroundNode.descriptionForType(SettingsViewController.currentClockSetting.faceBackgroundType)
        case "faceForegroundTypeTableViewCell":
            settingText = FaceForegroundNode.descriptionForType(SettingsViewController.currentClockSetting.faceForegroundType)
            
        case "faceBackgroundColorsTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceMaterialName
        case "mainBackgroundColorsTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockCasingMaterialName
        case "handsOptionsSettingsTableViewCellID":
            let shouldShowHandOutlines = SettingsViewController.currentClockSetting.clockFaceSettings?.shouldShowHandOutlines
            if (shouldShowHandOutlines == true) {
                settingText = "show outlines"
            } else {
                settingText = "no outlines"
            }
        case "faceForegroundOptionsSettingsTableViewCellID":
            if let overlaySettings = SettingsViewController.currentClockSetting.clockOverlaySettings {
                if SettingsViewController.currentClockSetting.faceForegroundType == .AnimatedPhysicsField {
                    settingText += FaceForegroundNode.descriptionForPhysicsFields(overlaySettings.fieldType)
                    settingText += " " + ClockOverlaySetting.descriptionForOverlayShapeType(overlaySettings.shapeType)
                }
                if SettingsViewController.currentClockSetting.faceForegroundType != .AnimatedPong && SettingsViewController.currentClockSetting.faceForegroundType != .None {
                    settingText += " " + overlaySettings.itemSize.description
                    settingText += " " + overlaySettings.itemStrength.description
                }
            }
        case "secondHandSettingsTableViewCell":
            settingText = SecondHandNode.descriptionForType((SettingsViewController.currentClockSetting.clockFaceSettings?.secondHandType)!)
        case "secondhandAnimationSettingsTableViewCellID":
            settingText = SecondHandNode.descriptionForMovement((SettingsViewController.currentClockSetting.clockFaceSettings?.secondHandMovement)!)
        case "secondHandColorsTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceSettings?.secondHandMaterialName ?? ""
            
        case "minuteHandSettingsTableViewCell":
            settingText = MinuteHandNode.descriptionForType((SettingsViewController.currentClockSetting.clockFaceSettings?.minuteHandType)!)
        case "minutehandAnimationSettingsTableViewCellID":
            settingText = MinuteHandNode.descriptionForMovement((SettingsViewController.currentClockSetting.clockFaceSettings?.minuteHandMovement)!)
        case "minuteHandColorTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceSettings?.minuteHandMaterialName ?? ""
            
        case "hourHandSettingsTableViewCell":
            settingText = HourHandNode.descriptionForType((SettingsViewController.currentClockSetting.clockFaceSettings?.hourHandType)!)
        case "hourHandColorTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceSettings?.hourHandMaterialName ?? ""
        case "handOutlineColorTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceSettings?.handOutlineMaterialName ?? ""
        case "handsEffectsTableViewCellID":
            var secondHandVal:Float = 0.0
            var minuteHandVal:Float = 0.0
            var hourHandVal:Float = 0.0
            if let secWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.handEffectWidths[safe: 0] { secondHandVal = secWidth }
            if let minWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.handEffectWidths[safe: 1] { minuteHandVal = minWidth }
            if let hourWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.handEffectWidths[safe: 2] { hourHandVal = hourWidth }
            settingText = String(secondHandVal) + "," + String(minuteHandVal) + "," + String(hourHandVal)
        case "ringsAlphaTableViewCellID":
            var secondHandVal:Float = 0.0
            var minuteHandVal:Float = 0.0
            var hourHandVal:Float = 0.0
            if let secWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.ringAlphas[safe: 0] { secondHandVal = secWidth }
            if let minWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.ringAlphas[safe: 1] { minuteHandVal = minWidth }
            if let hourWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.ringAlphas[safe: 2] { hourHandVal = hourWidth }
            settingText = String(secondHandVal) + "," + String(minuteHandVal) + "," + String(hourHandVal)
        case "handsAlphaTableViewCellID":
            var secondHandVal:Float = 0.0
            var minuteHandVal:Float = 0.0
            var hourHandVal:Float = 0.0
            if let secWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.handAlphas[safe: 0] { secondHandVal = secWidth }
            if let minWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.handAlphas[safe: 1] { minuteHandVal = minWidth }
            if let hourWidth = SettingsViewController.currentClockSetting.clockFaceSettings?.handAlphas[safe: 2] { hourHandVal = hourWidth }
            settingText = String(secondHandVal) + "," + String(minuteHandVal) + "," + String(hourHandVal)
        case "ringShapeSettingsTableViewCellID":
            settingText = ClockRingSetting.descriptionForRingRenderShapes((SettingsViewController.currentClockSetting.clockFaceSettings?.ringRenderShape)!)
        case "ringMainColorsTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceSettings?.ringMaterials[0] ?? ""
        case "ringSecondaryColorsTableViewCell":
            settingText = SettingsViewController.currentClockSetting.clockFaceSettings?.ringMaterials[1] ?? ""
        case "ringThirdColorsTableViewCell":
            if let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings {
                if clockFaceSettings.ringMaterials.count>2 {
                settingText = clockFaceSettings.ringMaterials[2]
                }
                    
            }
        case "ringEditorTableViewCellID":
            settingText = String( SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.count )
            
            default: settingText = ""
        }
        return settingText
    }
    
    func setSectionDataForOptions() {
        let options = Defaults.getOptions()
        
        func removeSectionItemsForCategory (category: String) {
            for (sectionIndex, section) in sectionsData.enumerated() {
                for (itemIndex,item) in section.enumerated().reversed() { //reverse so it pops from the ends
                    if (item["category"] == category) {
                        sectionsData[sectionIndex].remove(at: itemIndex)
                    }
                }
            }
        }
        
        if options.showAdvancedOptionsKey == nil || options.showAdvancedOptionsKey == false {
            // remove non-advanced items
            removeSectionItemsForCategory(category: "advanced")
            removeSectionItemsForCategory(category: "path-render")
        }

    }
    
    func reloadAfterGroupChange() {
        self.tableView.reloadData()
        selectCurrentSettings(animated: false)
    }
    
    func selectCurrentSettings(animated: Bool) {
        //loop through the cells and tell them to select their collectionView current item
        for sectionNum in 0 ... sectionsData[currentGroupIndex].count {
            let indexPath = IndexPath.init(row: 0, section: sectionNum)
            
            //tell the header to update it value
            if let headerView = self.tableView.headerView(forSection: sectionNum) {
                if let headerCell = headerView as? SettingsTableHeaderViewCell {
                    headerCell.settingLabel.text = valueForHeader( section: sectionNum)
                }
            }
            //get the cell, tell is to select its current item ( knows its own type to be able to select it )
            if let currentcell = self.tableView.cellForRow(at: indexPath) as? WatchSettingsSelectableTableViewCell {
                currentcell.chooseSetting(animated: true)
            }
        
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsData[currentGroupIndex].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellId = sectionsData[currentGroupIndex][indexPath.section]["cellID"]!
        if cellId == "ringEditorTableViewCellID" {
            //call segue
            self.performSegue(withIdentifier: "callDecoratorPreviewSegueID", sender: nil)
            //
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = sectionsData[currentGroupIndex][indexPath.section]["rowHeight"]!
        let doubleVal = Double.init(rowHeight)
        return CGFloat( doubleVal ?? 100.0 )
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingsTableHeaderViewID") as? SettingsTableHeaderViewCell {
            headerCell.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            headerCell.settingLabel.text = valueForHeader( section: section)
            return headerCell
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsData[currentGroupIndex][section]["title"]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = sectionsData[currentGroupIndex][indexPath.section]["cellID"]!
        if cellId == "ringEditorTableViewCellID" {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DecoratorRingsSettingsTableViewCell
            
            let ringNum = String( SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.count )
            cell.decoratorRingsLabel.text = ringNum + " parts make up this face"
            cell.cellId = cellId //important for updating the proper header cell values later!
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WatchSettingsSelectableTableViewCell
            cell.cellId = cellId //important for updating the proper header cell values later!
            cell.chooseSetting(animated: true)
            
            let selectedBackGroundView = UIView.init()
            selectedBackGroundView.backgroundColor = AppUISettings.settingsTableCellBackgroundColor
            cell.selectedBackgroundView = selectedBackGroundView
            
            return cell
        }
    }
    
    @objc func onNotification(notification:Notification)
    {
        
        func updateHeaderSection( section: Int ) {
            if let sectionHeader = self.tableView.headerView(forSection: section) as? SettingsTableHeaderViewCell {
                sectionHeader.settingLabel.text = valueForHeader( section: section)
            }
        }
        
        if let data = notification.userInfo as? [String: String], let cellID = data["cellId"] {
            
            //check to see if we need to reload another cell based on a settings change
            var reloadCellIDOptional:String? = nil
            if let reloadCellID = data["reloadCellId"], let dataType = data["settingType"] {
                if dataType == "faceForegroundType" {
                    reloadCellIDOptional = reloadCellID
                }
            }
            
            for (index,row) in sectionsData[currentGroupIndex].enumerated() {
                if row["cellID"] == cellID {
                    //debugPrint("header reload, index" + String(index) )
                    updateHeaderSection( section:index )
                }
                //handle reloading cells if needed due to another cell changing an option , IE sending data["reloadCellId"] in userInfo
                if reloadCellIDOptional != nil && row["cellID"] == reloadCellIDOptional {
                    self.tableView.reloadSections(IndexSet.init(integer: index), with: UITableView.RowAnimation.none)
                }
            }
        } else {
            debugPrint("!!! tableView full reload!!, need to send along cellId to be able to reload on header / values... WatchSettingsTableViewController")
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove data for table cells due to options
        setSectionDataForOptions()
        
        tableView.register(UINib(nibName: "SettingsTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SettingsTableHeaderViewID")
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil)
    }
    
}

