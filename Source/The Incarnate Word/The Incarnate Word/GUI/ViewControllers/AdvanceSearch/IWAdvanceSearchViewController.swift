//
//  IWAdvanceSearchViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 24/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit


class IWAdvanceSearchViewController: UIViewController,ContainerViewDelegate,SelectionViewDelegate,UISearchBarDelegate,UITableViewDelegate
{
    enum EnumSelectionListType
    {
        case SelectionListTypeAuthor
        case SelectionListTypeCollection
        case SelectionListTypeVolume
        case SelectionListTypeYear
        case SelectionListTypeMonth
        case SelectionListTypeDate
    }
    

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    
    var vcContainerTable:IWAdvanceSearchContainerTableViewController!
    var vcSelection:IWSelectionViewController?
    var _listType:EnumSelectionListType = .SelectionListTypeAuthor
    var _selectedSegment:EnumSelectedSegment = .SelectedSegmentFilter
    
    internal var _strSearch:String?
    var _strAuther:String = ""
    var _strCompilation:String = ""
    var _strVolume:String = ""
    
    var _strYear:String = ""
    var _strMonth:String = ""
    var _strDay:String = ""
    
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
        searchBar.text = _strSearch
        
        vcContainerTable.cellCompilation.contentView.alpha = 0.5
        vcContainerTable.cellVolume.contentView.alpha = 0.5
        
        
        let attr = NSDictionary(object: UIFont(name: FONT_TITLE_REGULAR, size: 16.0)!, forKey: NSFontAttributeName)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] , forState: .Normal)
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject)
    {
        if segmentControl.selectedSegmentIndex == 0
        {
            _selectedSegment = .SelectedSegmentFilter
        }
        else if segmentControl.selectedSegmentIndex == 1
        {
            _selectedSegment = .SelectedSegmentGoToDate
        }
        
        vcContainerTable._selectedSegment = _selectedSegment
        vcContainerTable.updateTableContent()
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

        vc!.strSearch = ""
        vc!.strAuther = ""
        vc!.strCollection = ""
        vc!.strVolume = ""
        
        vc!.strYear = ""
        vc!.strMonth = ""
        vc!.strDay = ""
        
        vc!._selectedSegment = self._selectedSegment
        vc!.strAuther       = _strAuther == "" ? "" :(_strAuther == "Sri Aurobindo" ? "sa": "m")

        
        if self._selectedSegment == .SelectedSegmentFilter
        {
            if searchBar.text == nil || searchBar.text ==  ""
            {
                
                let alert = UIAlertController(title: "Error", message: "Please enter search text.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
        
            //http://incarnateword.in/search?q=mother&auth=sa&comp=sabcl&vol=01
            vc!.strSearch       = searchBar.text!
            
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
            vc!.strVolume       = arr.count >= 2 ? arr[0] : ""
            
            
        }
        else if self._selectedSegment == .SelectedSegmentGoToDate
        {
            if _strYear ==  "" ||  _strYear ==  "Any"
            {
                let alert = UIAlertController(title: "Error", message: "Please select year.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
            vc!.strYear = _strYear
            vc!.strMonth = _strMonth
            vc!.strDay = _strDay
        }
        
        
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    

    //MARK: ContainerViewDelegate

    func cellSelectedAuther()
    {
        _listType = .SelectionListTypeAuthor

        print("Auther Cell Selected")
        vcSelection?.arrDataSource = ["Sri Aurobindo","The Mother"]
        
        if _strAuther != ""
        {
            vcSelection?.arrPreviousSelection = [_strAuther]
        }
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
        
        if _strCompilation != ""
        {
            vcSelection?.arrPreviousSelection = [_strCompilation]
        }
        
        if _strAuther == "Sri Aurobindo"
        {
            vcSelection?.arrDataSource = ["Birth Centenary Library","Complete Works"]
            self.navigationController?.pushViewController(vcSelection!, animated: true)

        }
        else if _strAuther == "The Mother"
        {
            vcSelection?.arrDataSource = ["Collected Works","Agenda"]
            self.navigationController?.pushViewController(vcSelection!, animated: true)
        }
        
    }
    
    func cellSelectedVolume()
    {
        _listType = .SelectionListTypeVolume

        print("Volume Cell Selected")
        
        if _strVolume != ""
        {
            vcSelection?.arrPreviousSelection = [_strVolume]
        }

        
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
            
            self.navigationController?.pushViewController(vcSelection!, animated: true)

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
            
            self.navigationController?.pushViewController(vcSelection!, animated: true)
            
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
            
            self.navigationController?.pushViewController(vcSelection!, animated: true)
            
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
            
            self.navigationController?.pushViewController(vcSelection!, animated: true)
            
        }
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
    
    
    func cellSelectedYear()
    {
        _listType = .SelectionListTypeYear
        
        print("Year Cell Selected")
        
        if _strYear != ""
        {
            vcSelection?.arrPreviousSelection = [_strYear]
        }
        
        vcSelection?.arrDataSource =
        ["Any",
        "1973",
        "1972",
        "1971",
        "1970",
        "1969",
        "1968",
        "1967",
        "1966",
        "1965",
        "1964",
        "1963",
        "1962",
        "1961",
        "1960",
        "1959",
        "1958",
        "1957",
        "1956",
        "1955",
        "1954",
        "1953",
        "1952",
        "1951",
        "1950",
        "1949",
        "1948",
        "1947",
        "1946",
        "1945",
        "1944",
        "1943",
        "1942",
        "1941",
        "1940",
        "1939",
        "1938",
        "1937",
        "1936",
        "1935",
        "1934",
        "1933",
        "1932",
        "1931",
        "1930",
        "1929",
        "1928",
        "1927",
        "1926",
        "1925",
        "1924",
        "1923",
        "1922",
        "1921",
        "1920",
        "1919",
        "1918",
        "1917",
        "1916",
        "1915",
        "1914",
        "1913",
        "1912",
        "1911",
        "1910",
        "1909",
        "1908",
        "1907",
        "1906",
        "1905",
        "1904",
        "1903",
        "1902",
        "1901",
        "1900",
        "1899",
        "1898",
        "1897",
        "1896",
        "1895",
        "1894",
        "1893"]
        
        self.navigationController?.pushViewController(vcSelection!, animated: true)

    }
    
    func cellSelectedMonth()
    {
        _listType = .SelectionListTypeMonth
        
        print("Month Cell Selected")
        
        if _strMonth != ""
        {
            vcSelection?.arrPreviousSelection = [_strMonth]
        }
        
        vcSelection?.arrDataSource =
            ["January",
             "February",
             "March",
             "April",
             "May",
             "June",
             "July",
             "August",
             "September",
             "October",
             "November",
             "December"]
        
        self.navigationController?.pushViewController(vcSelection!, animated: true)
    }
    
    func cellSelectedDate()
    {
        
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        var components:NSDateComponents = NSDateComponents()
        
        
        let number = Int(_strYear)
        
        components.year = number!
        
        let arrTemp:[String] =
        
        ["January",
         "February",
         "March",
         "April",
         "May",
         "June",
         "July",
         "August",
         "September",
         "October",
         "November",
         "December"]
        
        components.month = arrTemp.indexOf(_strMonth)! + 1;
        var date:NSDate = calendar.dateFromComponents(components)!
        var range:NSRange = calendar.rangeOfUnit(.Day, inUnit: .Month , forDate: date)
        
        print(range.length)
        

        _listType = .SelectionListTypeDate
        
        print("Date Cell Selected")
        
        if _strDay != ""
        {
            vcSelection?.arrPreviousSelection = [_strDay]
        }
        
        
        var arrDate:[String] = []
        
        var i = 1
        
        while i <= range.length
        {
            arrDate.append(String(i))
            i+=1
        }
        
        vcSelection?.arrDataSource = arrDate
 
        
        self.navigationController?.pushViewController(vcSelection!, animated: true)
        
    }
    
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
            vcContainerTable.cellCompilation.contentView.alpha = 1.0
            vcContainerTable.cellVolume.contentView.alpha = 0.5
            
            break;
            
        case .SelectionListTypeCollection  :
            
            _strCompilation = selectionItems[0] as! String
            _strVolume = ""
            
            vcContainerTable.cellVolume.contentView.alpha = 1.0
            break;
            
        case .SelectionListTypeVolume  :
            
            _strVolume = selectionItems[0] as! String
            break;
            
        case .SelectionListTypeYear  :
            
            _strYear = selectionItems[0] as! String
            break;
            
        case .SelectionListTypeMonth  :
            
            _strMonth = selectionItems[0] as! String
            break;
            
        case .SelectionListTypeDate  :
            
            _strDay = selectionItems[0] as! String
            break;
        }
        
        
        vcContainerTable.cellAuther.detailTextLabel?.text = _strAuther
        vcContainerTable.cellCompilation.detailTextLabel?.text = _strCompilation
        vcContainerTable.cellVolume.detailTextLabel?.text = _strVolume
        
        vcContainerTable.cellYear.detailTextLabel?.text = _strYear
        vcContainerTable.cellMonth.detailTextLabel?.text = _strMonth
        vcContainerTable.cellDate.detailTextLabel?.text = _strDay
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