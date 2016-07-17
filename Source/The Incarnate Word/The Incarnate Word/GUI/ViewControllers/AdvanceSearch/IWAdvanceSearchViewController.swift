//
//  IWAdvanceSearchViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 24/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit


class IWAdvanceSearchViewController: UIViewController,ContainerViewDelegate,SelectionViewDelegate,UISearchBarDelegate
{
    enum EnumSelectionListType
    {
        case SelectionListTypeAuthor
        case SelectionListTypeCollection
        case SelectionListTypeVolume
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var vcContainerTable:IWAdvanceSearchContainerTableViewController!
    var vcSelection:IWSelectionViewController?
    var _listType:EnumSelectionListType = .SelectionListTypeAuthor
    var _strSearch:String = ""
    var _strAuther:String = ""
    var _strCompilation:String = ""
    var _strVolume:String = ""
    
    
    //MARK: View Life Cycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        vcSelection = (self.storyboard?.instantiateViewControllerWithIdentifier("IWSelectionViewController"))! as? IWSelectionViewController
        vcSelection?.delegateSelectionView = self
        searchBar.returnKeyType = .Done
        searchBar.showsCancelButton = false
        

    }
    
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "AdvanceSearchTableContainer"
        {
            vcContainerTable = segue.destinationViewController as! IWAdvanceSearchContainerTableViewController
            vcContainerTable.delegateContainerView = self;
        }
    }
    
    
    //MARK: IBACtions
    
    @IBAction func buttonAdvanceSearchClicked(sender: AnyObject)
    {
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("IWAdvanceSearchResultViewController"))! as? IWAdvanceSearchResultViewController
        
        //http://incarnateword.in/search?q=mother&auth=sa&comp=sabcl&vol=01
        vc!.strSearch       = searchBar.text!
        vc!.strAuther       = _strAuther == "" ? "" :(_strAuther == "Sri Aurobindo" ? "sa": "m")
        
        var strTempCollection:String = ""
        
        if(_strCompilation == "Birth Centenary Library")
        {
            strTempCollection = "sabcl"
        }
        else if(_strCompilation == "Complete Works")
        {
            strTempCollection = "cwsa"
        }
        else if(_strCompilation == "Collected Works")
        {
            strTempCollection = "cwm"
        }
        else if(_strCompilation == "Agenda")
        {
            strTempCollection = "agenda"
        }
        vc!.strCollection   = strTempCollection
        
        var arr:[String] = _strVolume.componentsSeparatedByString(":")
        vc!.strVolume       = arr.count > 0 ? arr[0] : ""
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    

    //MARK: ContainerViewDelegate

    func cellSelectedAuther()
    {
        _listType = .SelectionListTypeAuthor

        print("Auther Cell Selected")
        vcSelection?.arrDataSource = ["Sri Aurobindo","The Mother"]
        self.navigationController?.pushViewController(vcSelection!, animated: true)
        
    }
    

    
    func cellSelectedCompilation()
    {

        
        
        _listType = .SelectionListTypeCollection

        
        //Birth Centenary Library   sabcl
        //Complete Works            cwsa
        
        //Collected Works   cwm
        //Agenda            agenda
        
        print("Compilation Cell Selected")
        
        if _strAuther == "Sri Aurobindo"
        {
            vcSelection?.arrDataSource = ["Birth Centenary Library","Complete Works"]
        }
        else if _strAuther == "The Mother"
        {
            vcSelection?.arrDataSource = ["Collected Works","Agenda"]
        }
        
        self.navigationController?.pushViewController(vcSelection!, animated: true)
    }
    
    func cellSelectedVolume()
    {
        _listType = .SelectionListTypeVolume

        print("Volume Cell Selected")

        vcSelection?.arrDataSource = ["One","Two"]
        
        if _strCompilation == "Birth Centenary Library"
        {
        
            vcSelection?.arrDataSource =

            ["Any",
            "01: Bande Mataram",
            "02: Karmayogin",
            "03: The Harmony of Virtue",
            "04: Writings in Bengali",
            "05: Collected Poems",
            "06: Collected Plays and Short Stories - I",
            "07: Collected Plays and Short Stories - II",
            "08: Translations",
            "09: The Future Poetry",
            "10: The Secret of the Veda",
            "11: Hymns to the Mystic Fire",
            "12: The Upanishads",
            "13: Essays on the Gita",
            "14: The Foundations of Indian Culture",
            "15: Social and Political Thought",
            "16: The Supramental Manifestation",
            "17: The Hour of God",
            "18: The Life Divine - I",
            "19: The Life Divine - II",
            "20: The Synthesis of Yoga - I",
            "21: The Synthesis of Yoga - II",
            "22: Letters on Yoga - I",
            "23: Letters on Yoga - II",
            "24: Letters on Yoga - III",
            "25: The Mother",
            "26: On Himself",
            "27: Supplement",
            "28: Savitri - I",
            "29: Savitri - II"]
            
        }
        else if _strCompilation == "Complete Works"
        {
            vcSelection?.arrDataSource =
                
            ["Any",
            "01: Early Cultural Writings",
            "02: Collected Poems",
            "03: Collected Plays and Stories - I",
            "04: Collected Plays and Stories - II",
            "05: Translations",
            "06: Bande Mataram - I",
            "07: Bande Mataram - II",
            "08: Karmayogin",
            "10: Record of Yoga - I",
            "11: Record of Yoga - II",
            "12: Essays Divine and Human",
            "13: Essays in Philosophy and Yoga",
            "15: The Secret of the Veda",
            "16: Hymns to the Mystic Fire",
            "17: Isha Upanishad",
            "18: Kena and Other Upanishads",
            "19: Essays on the Gita",
            "20: The Renaissance in India",
            "21: The Life Divine - I",
            "22: The Life Divine - II",
            "23: The Synthesis of Yoga - I",
            "24: The Synthesis of Yoga - II",
            "25: The Human Cycle",
            "26: The Future Poetry",
            "27: Letters on Poetry and Art",
            "28: Letters on Yoga - I",
            "29: Letters on Yoga - II",
            "30: Letters on Yoga - III",
            "31: Letters on Yoga - IV",
            "32: The Mother with Letters on The Mother",
            "33: Savitri - I",
            "34: Savitri - II",
            "35: Letters on Himself and the Ashram",
            "36: Autobiographical Notes and Other Writings of Historical Interest"]
        }
        else if _strCompilation == "Collected Works"
        {
            vcSelection?.arrDataSource =
            ["Any",
            "01: Prayers and Meditations",
            "02: Words of Long Ago",
            "03: Questions and Answers (1929 - 1931)",
            "04: Questions and Answers (1950 - 1951)",
            "05: Questions and Answers (1953)",
            "06: Questions and Answers (1954)",
            "07: Questions and Answers (1955)",
            "08: Questions and Answers (1956)",
            "09: Questions and Answers (1957 - 1958)",
            "10: On Thoughts and Aphorisms",
            "11: Notes on the Way",
            "12: On Education",
            "13: Words of the Mother - I",
            "14: Words of the Mother - II",
            "15: Words of the Mother - III",
            "16: Some Answers from the Mother",
            "17: More Answers from the Mother"]
        }
        else if _strCompilation == "Agenda"
        {
            vcSelection?.arrDataSource =
            ["Any",
            "01: 1951-1960",
            "02: 1961",
            "03: 1962",
            "04: 1963",
            "05: 1964",
            "06: 1965",
            "07: 1966",
            "08: 1967",
            "09: 1968",
            "10: 1969",
            "11: 1970",
            "12: 1971",
            "13: 1972-1973"]
        }
        
        
        self.navigationController?.pushViewController(vcSelection!, animated: true)
    }
    
    /*
     
     
     <select class="form-control input-sm select-custom" id="volume">
     <option value="">Any</option>
     <option value="01">01: Bande Mataram</option>
     <option value="02">02: Karmayogin</option>
     <option value="03">03: The Harmony of Virtue</option>
     <option value="04">04: Writings in Bengali</option>
     <option value="05">05: Collected Poems</option>
     <option value="06">06: Collected Plays and Short Stories - I</option>
     <option value="07">07: Collected Plays and Short Stories - II</option>
     <option value="08">08: Translations</option>
     <option value="09">09: The Future Poetry</option>
     <option value="10">10: The Secret of the Veda</option>
     <option value="11">11: Hymns to the Mystic Fire</option>
     <option value="12">12: The Upanishads</option>
     <option value="13">13: Essays on the Gita</option>
     <option value="14">14: The Foundations of Indian Culture</option>
     <option value="15">15: Social and Political Thought</option>
     <option value="16">16: The Supramental Manifestation</option>
     <option value="17">17: The Hour of God</option>
     <option value="18">18: The Life Divine - I</option>
     <option value="19">19: The Life Divine - II</option>
     <option value="20">20: The Synthesis of Yoga - I</option>
     <option value="21">21: The Synthesis of Yoga - II</option>
     <option value="22">22: Letters on Yoga - I</option>
     <option value="23">23: Letters on Yoga - II</option>
     <option value="24">24: Letters on Yoga - III</option>
     <option value="25">25: The Mother</option>
     <option value="26">26: On Himself</option>
     <option value="27">27: Supplement</option>
     <option value="28">28: Savitri - I</option>
     <option value="29">29: Savitri - II</option>
     </select>
     
     
     <select class="form-control input-sm select-custom" id="volume">
     <option value="">Any</option>
     <option value="01">01: Early Cultural Writings</option>
     <option value="02">02: Collected Poems</option>
     <option value="03">03: Collected Plays and Stories - I</option>
     <option value="04">04: Collected Plays and Stories - II</option>
     <option value="05">05: Translations</option>
     <option value="06">06: Bande Mataram - I</option>
     <option value="07">07: Bande Mataram - II</option>
     <option value="08">08: Karmayogin</option>
     <option value="10">10: Record of Yoga - I</option>
     <option value="11">11: Record of Yoga - II</option>
     <option value="12">12: Essays Divine and Human</option>
     <option value="13">13: Essays in Philosophy and Yoga</option>
     <option value="15">15: The Secret of the Veda</option>
     <option value="16">16: Hymns to the Mystic Fire</option>
     <option value="17">17: Isha Upanishad</option>
     <option value="18">18: Kena and Other Upanishads</option>
     <option value="19">19: Essays on the Gita</option>
     <option value="20">20: The Renaissance in India</option>
     <option value="21">21: The Life Divine - I</option>
     <option value="22">22: The Life Divine - II</option>
     <option value="23">23: The Synthesis of Yoga - I</option>
     <option value="24">24: The Synthesis of Yoga - II</option>
     <option value="25">25: The Human Cycle</option>
     <option value="26">26: The Future Poetry</option>
     <option value="27">27: Letters on Poetry and Art</option>
     <option value="28">28: Letters on Yoga - I</option>
     <option value="29">29: Letters on Yoga - II</option>
     <option value="30">30: Letters on Yoga - III</option>
     <option value="31">31: Letters on Yoga - IV</option>
     <option value="32">32: The Mother with Letters on The Mother</option>
     <option value="33">33: Savitri - I</option>
     <option value="34">34: Savitri - II</option>
     <option value="35">35: Letters on Himself and the Ashram</option>
     <option value="36">36: Autobiographical Notes and Other Writings of Historical Interest</option>
     </select>
     
     
     
     
     //The Mother//
     Collected Works   cwm

     <select class="form-control input-sm select-custom" id="volume">
     <option value="">Any</option>
     <option value="01">01: Prayers and Meditations</option>
     <option value="02">02: Words of Long Ago</option>
     <option value="03">03: Questions and Answers (1929 - 1931)</option>
     <option value="04">04: Questions and Answers (1950 - 1951)</option>
     <option value="05">05: Questions and Answers (1953)</option>
     <option value="06">06: Questions and Answers (1954)</option>
     <option value="07">07: Questions and Answers (1955)</option>
     <option value="08">08: Questions and Answers (1956)</option>
     <option value="09">09: Questions and Answers (1957 - 1958)</option>
     <option value="10">10: On Thoughts and Aphorisms</option>
     <option value="11">11: Notes on the Way</option>
     <option value="12">12: On Education</option>
     <option value="13">13: Words of the Mother - I</option>
     <option value="14">14: Words of the Mother - II</option>
     <option value="15">15: Words of the Mother - III</option>
     <option value="16">16: Some Answers from the Mother</option>
     <option value="17">17: More Answers from the Mother</option>
     </select>
     
     //Agenda            agenda

     <select class="form-control input-sm select-custom" id="volume">
     <option value="">Any</option>
     <option value="01">01: 1951-1960</option>
     <option value="02">02: 1961</option>
     <option value="03">03: 1962</option>
     <option value="04">04: 1963</option>
     <option value="05">05: 1964</option>
     <option value="06">06: 1965</option>
     <option value="07">07: 1966</option>
     <option value="08">08: 1967</option>
     <option value="09">09: 1968</option>
     <option value="10">10: 1969</option>
     <option value="11">11: 1970</option>
     <option value="12">12: 1971</option>
     <option value="13">13: 1972-1973</option>
     </select>
     
     */
    //MARK: ContainerViewDelegate
    
    func selectionViewSelectedItems(selectionItems:[AnyObject])
    {
        if selectionItems.count == 0
        {
            return
        }
        
        switch(_listType)
        {
        case .SelectionListTypeAuthor  :
            
            _strAuther = selectionItems[0] as! String
            _strCompilation = ""
            _strVolume = ""
            break;
            
        case .SelectionListTypeCollection  :
            
            _strCompilation = selectionItems[0] as! String
            _strVolume = ""
            break;
            
        case .SelectionListTypeVolume  :
            
             _strVolume = selectionItems[0] as! String
            break;
        }
        
        
        vcContainerTable.cellAuther.detailTextLabel?.text = _strAuther
        vcContainerTable.cellCompilation.detailTextLabel?.text = _strCompilation
        vcContainerTable.cellVolume.detailTextLabel?.text = _strVolume
    }

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}