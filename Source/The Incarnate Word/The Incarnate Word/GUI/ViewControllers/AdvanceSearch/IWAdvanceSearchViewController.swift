//
//  IWAdvanceSearchViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 24/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

class IWAdvanceSearchViewController: UIViewController,ContainerViewDelegate,SelectionViewDelegate,UISearchBarDelegate,UITableViewDelegate,WebServiceDelegate
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
    @IBOutlet weak var buttonSearch: UIButton!

    
    var vcContainerTable:IWAdvanceSearchContainerTableViewController!
    var vcSelection:IWSelectionViewController?
    var _listType:EnumSelectionListType = .SelectionListTypeAuthor
    var _selectedSegment:EnumSelectedSegment = .SelectedSegmentFilter
    
    internal var _strSearch:String?
    var _arrAuther:[String] = []
    var _strCompilation:String = ""
    var _strVolume:String = ""
    
    var _strYear:String = ""
    var _strMonth:String = ""
    var _strDay:String = ""
    
    
    
    private var wsCompilationSABCL: IWCompilationWebService!
    private var wsCompilationCWSA: IWCompilationWebService!
    private var wsCompilationCWM: IWCompilationWebService!
    private var wsCompilationAGENDA: IWCompilationWebService!
    
    private var compilationSABCL: IWCompilationStructure!
    private var compilationCWSA: IWCompilationStructure!
    private var compilationCWM: IWCompilationStructure!
    private var compilationAGENDA: IWCompilationStructure!
    
    
    
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
        
        self.disableCell(vcContainerTable.cellCompilation, shouldDisable: true)
        self.disableCell(vcContainerTable.cellVolume, shouldDisable: true)
        
        self.disableCell(vcContainerTable.cellDate, shouldDisable: true)
        
        
        let attr = NSDictionary(object: UIFont(name: FONT_TITLE_REGULAR, size: 16.0)!, forKey: NSFontAttributeName)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] , forState: .Normal)
        
        self.loadAllTOC()
        
        self.navigationItem.title = "Advanced Search"
        
        let backButton = UIBarButtonItem(
            title: "",
            style: UIBarButtonItemStyle.Plain,
            target: nil,
            action: nil
        )

        self.navigationItem.backBarButtonItem = backButton
        
        self.buttonSearch.layer.cornerRadius = 10.0
    }
    
    func loadAllTOC()
    {
        self.wsCompilationSABCL = IWCompilationWebService(path: "sabcl", andDelegate: self)
        self.wsCompilationSABCL.sendAsyncRequest()
        
        self.wsCompilationCWSA = IWCompilationWebService(path: "cwsa", andDelegate: self)
        self.wsCompilationCWSA.sendAsyncRequest()
        
        self.wsCompilationCWM = IWCompilationWebService(path: "cwm", andDelegate: self)
        self.wsCompilationCWM.sendAsyncRequest()
        
        self.wsCompilationAGENDA = IWCompilationWebService(path: "agenda", andDelegate: self)
        self.wsCompilationAGENDA.sendAsyncRequest()
    }
    
    func requestSucceed(webService: BaseWebService, response responseModel: AnyObject)
    {
        if webService === self.wsCompilationSABCL
        {
            compilationSABCL = responseModel as!  IWCompilationStructure

        }
        else if webService === self.wsCompilationCWSA
        {
            compilationCWSA = responseModel as!  IWCompilationStructure

        }
        else if webService === self.wsCompilationCWM
        {
            compilationCWM = responseModel as!  IWCompilationStructure

        }
        else if webService === self.wsCompilationAGENDA
        {
            compilationAGENDA = responseModel as!  IWCompilationStructure
        }
    }
    
    func requestFailed(webService: BaseWebService, error: WSError)
    {
        
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject)
    {
        if segmentControl.selectedSegmentIndex == 0
        {
            _selectedSegment = .SelectedSegmentFilter
            
            if _arrAuther.count == 2
            {
                _arrAuther.removeAtIndex(1)
                vcContainerTable.cellAuther.detailTextLabel?.text = _arrAuther[0]
            }
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
        
        
        if _arrAuther.count == 1
        {
            vc!.strAuther       = (_arrAuther[0] == "Sri Aurobindo" ? "sa": "m")
        }

        
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
            
            vc!.strYear  = _strYear
            
            
            let arrTemp:[String] =
                
                ["Any",
                 "January",
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
            
            if _strMonth !=  "" &&  _strMonth !=  "Any"
            {
                let index:Int = arrTemp.indexOf(_strMonth)!
                vc!.strMonth = "\(index)"
                vc!.strDay   = (_strDay ==  "Any" ? "" :  _strDay)
            }
           

        }
        
        
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    

    //MARK: ContainerViewDelegate

    func cellSelectedAuther()
    {
        if self._selectedSegment == .SelectedSegmentFilter
        {
            vcSelection?.bAllowMultipleSelection = false
        }
        else if self._selectedSegment == .SelectedSegmentGoToDate
        {
            vcSelection?.bAllowMultipleSelection = true

        }
        
        _listType = .SelectionListTypeAuthor

        print("Auther Cell Selected")
        vcSelection?.arrDataSource = ["Sri Aurobindo","The Mother"]
        
        if _arrAuther.count > 0
        {
            vcSelection?.arrPreviousSelection = _arrAuther
        }
        self.navigationController?.pushViewController(vcSelection!, animated: true)
        
    }
    

    
    func cellSelectedCompilation()
    {

        vcSelection?.bAllowMultipleSelection = false
        
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
        
        if _arrAuther[0] == "Sri Aurobindo"
        {
            vcSelection?.arrDataSource = ["Any","Birth Centenary Library","Complete Works"]
            self.navigationController?.pushViewController(vcSelection!, animated: true)

        }
        else if _arrAuther[0] == "The Mother"
        {
            vcSelection?.arrDataSource = ["Any","Collected Works","Agenda"]
            self.navigationController?.pushViewController(vcSelection!, animated: true)
        }
        
    }
    
    func cellSelectedVolume()
    {
        vcSelection?.bAllowMultipleSelection = false
        _listType = .SelectionListTypeVolume

        print("Volume Cell Selected")
        
        if _strVolume != ""
        {
            vcSelection?.arrPreviousSelection = [_strVolume]
        }

        
        if _strCompilation == "Birth Centenary Library"
        {
        
            vcSelection?.arrDataSource = ["Any"]
            
            
            if let _ = self.compilationSABCL
            {
                for item in self.compilationSABCL.arrVolumes
                {
                    let volume:IWVolumeStructure = item as! IWVolumeStructure
                    
                    vcSelection?.arrDataSource.append(String(format: "%@: %@",volume.strIndex,volume.strTitle))
                }
            }

            
            self.navigationController?.pushViewController(vcSelection!, animated: true)

        }
        else if _strCompilation == "Complete Works"
        {
            vcSelection?.arrDataSource = ["Any"]
            
            if let _ = self.compilationCWSA
            {
                for item in self.compilationCWSA.arrVolumes
                {
                    let volume:IWVolumeStructure = item as! IWVolumeStructure
                    
                    vcSelection?.arrDataSource.append(String(format: "%@: %@",volume.strIndex,volume.strTitle))
                }
            }
            
            self.navigationController?.pushViewController(vcSelection!, animated: true)
            
        }
        else if _strCompilation == "Collected Works"
        {
            vcSelection?.arrDataSource = ["Any"]
            
            if let _ = self.compilationCWM
            {
                for item in self.compilationCWM.arrVolumes
                {
                    let volume:IWVolumeStructure = item as! IWVolumeStructure
                    
                    vcSelection?.arrDataSource.append(String(format: "%@: %@",volume.strIndex,volume.strTitle))
                }
            }
            
            self.navigationController?.pushViewController(vcSelection!, animated: true)
            
        }
        else if _strCompilation == "Agenda"
        {
            vcSelection?.arrDataSource = ["Any"]
            
            if let _ = self.compilationAGENDA
            {
                for item in self.compilationAGENDA.arrVolumes
                {
                    let volume:IWVolumeStructure = item as! IWVolumeStructure
                    
                    vcSelection?.arrDataSource.append(String(format: "%@: %@",volume.strIndex,volume.strTitle))
                }
            }
            
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
        vcSelection?.bAllowMultipleSelection = false

        _listType = .SelectionListTypeYear
        
        print("Year Cell Selected")
        
        if _strYear != ""
        {
            vcSelection?.arrPreviousSelection = [_strYear]
        }
        
        var arrYear:[String] = ["Any"]
        /*
         Both 1890 - 1973

         Sir 1890 - 1950
         
         Mother 1893 - 1973
         
         */
        
        //Both combined
        var startYear:Int = 1890
        var endYear:Int = 1973
        
        if _arrAuther.count == 1
        {
            if _arrAuther[0] == "Sri Aurobindo" //Sir
            {
                endYear = 1950
            }
            else//Mother
            {
                startYear = 1893
            }
        }
        
        for(var year:Int = endYear; year >= startYear; year -= 1 )
        {
            arrYear.append(String(format:"%d",year))
        }
        
        vcSelection?.arrDataSource = arrYear
        
        
        self.navigationController?.pushViewController(vcSelection!, animated: true)

    }
    
    func cellSelectedMonth()
    {
        vcSelection?.bAllowMultipleSelection = false

        _listType = .SelectionListTypeMonth
        
        print("Month Cell Selected")
        
        if _strMonth != ""
        {
            vcSelection?.arrPreviousSelection = [_strMonth]
        }
        
        vcSelection?.arrDataSource =
            ["Any",
             "January",
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
        vcSelection?.bAllowMultipleSelection = false

        let calendar:NSCalendar = NSCalendar.currentCalendar()
        var components:NSDateComponents = NSDateComponents()
        
        
        let number = Int(_strYear)
        
        components.year = number!
        
        let arrTemp:[String] =
        
        ["Any",
         "January",
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
        
        components.month = arrTemp.indexOf(_strMonth)! ;
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
            
            _arrAuther = selectionItems as! [String]
            _strCompilation = ""
            _strVolume = ""
            
            self.disableCell(vcContainerTable.cellCompilation, shouldDisable: false)
            self.disableCell(vcContainerTable.cellVolume, shouldDisable: true)

            
            break;
            
        case .SelectionListTypeCollection  :
            
            _strCompilation = selectionItems[0] as! String
            _strVolume = ""
            
            if ( _strCompilation != "Any")
            {
                self.disableCell(vcContainerTable.cellVolume, shouldDisable: false)
            }

            break;
            
        case .SelectionListTypeVolume  :
            
            _strVolume = selectionItems[0] as! String
            
            break;
            
        case .SelectionListTypeYear  :
            
            _strYear = selectionItems[0] as! String
            
            if (_strYear == "Any"  || _strYear == ""  || _strMonth == "Any" ||  _strMonth == "")
            {
                self.disableCell(vcContainerTable.cellDate, shouldDisable: true)
            }
            else
            {
                self.disableCell(vcContainerTable.cellDate, shouldDisable: false)
            }
            
            
            break;
            
        case .SelectionListTypeMonth  :
            
            _strMonth = selectionItems[0] as! String
            
            if (_strYear == "Any"  || _strYear == ""  || _strMonth == "Any" ||  _strMonth == "")
            {
                self.disableCell(vcContainerTable.cellDate, shouldDisable: true)
            }
            else
            {
                self.disableCell(vcContainerTable.cellDate, shouldDisable: false)
            }
            
            break;
            
        case .SelectionListTypeDate  :
            
            _strDay = selectionItems[0] as! String
            break;
        }
        
        var strAuthers:String = ""
        
        for strAuther in _arrAuther {
            
            if strAuthers == ""
            {
                strAuthers = strAuthers + strAuther
            }
            else
            {
                strAuthers = strAuthers + ", " + strAuther
            }
        }
        
        vcContainerTable.cellAuther.detailTextLabel?.text = strAuthers
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
    
    private func disableCell(cell:UITableViewCell, shouldDisable bShouldDisable:Bool)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
       {
            dispatch_async(dispatch_get_main_queue(),
            {
                if bShouldDisable
                {
                    cell.contentView.alpha = 0.5
                    cell.userInteractionEnabled = false
                }
                else
                {
                    cell.contentView.alpha = 1.0
                    cell.userInteractionEnabled = true
                }
            })
       })
    }

}
