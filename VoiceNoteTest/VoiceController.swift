//
//  VoiceController.swift
//  VoiceNoteTest
//
//  Created by LiXT on 6/11/16.
//  Copyright © 2016 LiXT. All rights reserved.
//

import UIKit
import CoreData

class VoiceController: UIViewController, IFlySpeechRecognizerDelegate {
    
    var notes = [NSManagedObject]()
    
    var iflyRecognizerView: IFlyRecognizerView = IFlyRecognizerView() //带界面的识别对象
    
    var iFlySpeechRecognizer: IFlySpeechRecognizer!

    @IBOutlet weak var textView: UITextView!
    
    //var popUpView: PopupView
    
    var isCanceled: Bool = false
    
    var note: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.editable = true
        self.textView.backgroundColor = UIColor.lightGrayColor()
        
        

    }
    
    override func viewWillAppear(animated: Bool) {
        self.initRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveNote(sender: UIButton) {
        if textView.text != "" {
            PersistenceOperations.save(textView.text, flag: false)
            textView.text = ""
            let savingAlert = UIAlertController(title: "Message", message: "Saved successfully!", preferredStyle: UIAlertControllerStyle.Alert)
            let oKayAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) -> Void in }
            savingAlert.addAction(oKayAction)
            self.presentViewController(savingAlert, animated: true, completion: nil)
        }
        else {
            let savingAlert = UIAlertController(title: "Message", message: "Nothing to be saved!", preferredStyle: UIAlertControllerStyle.Alert)
            let oKayAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) -> Void in }
            savingAlert.addAction(oKayAction)
            self.presentViewController(savingAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func startListening(sender: AnyObject) {
        //重置识别结果，取消上一次听写
        self.textView.text = ""
        textView.resignFirstResponder()
        self.isCanceled = false
        if iFlySpeechRecognizer == nil {
            self.initRecognizer()
        }
        self.iFlySpeechRecognizer.cancel()
        
        //设置声音来源与识别结果格式
        self.iFlySpeechRecognizer.setParameter(IFLY_AUDIO_SOURCE_MIC, forKey: "audio_source")
        self.iFlySpeechRecognizer.setParameter("json", forKey: IFlySpeechConstant.RESULT_TYPE())
        
        let ret = self.iFlySpeechRecognizer.startListening()
        if !ret {
            //TODO:识别失败信息
            print("启动识别服务失败，请稍后重试")
        }
    }
    
    @IBAction func stopListening(sender: AnyObject) {
        self.iFlySpeechRecognizer.stopListening()
        textView.resignFirstResponder()
    }
    
    //初始化听写对象
    func initRecognizer() {
        if self.iFlySpeechRecognizer == nil {
            //创建听写对象
            self.iFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance() as! IFlySpeechRecognizer
            //设置听写模式
            self.iFlySpeechRecognizer.setParameter("", forKey: IFlySpeechConstant.PARAMS())
            self.iFlySpeechRecognizer.setParameter("iat", forKey: IFlySpeechConstant.IFLY_DOMAIN())
            //设置最长录音时间
            self.iFlySpeechRecognizer.setParameter("30000", forKey:IFlySpeechConstant.SPEECH_TIMEOUT())
            //设置后端点
            self.iFlySpeechRecognizer.setParameter("3000", forKey:IFlySpeechConstant.VAD_EOS())
            //设置前端点
            self.iFlySpeechRecognizer.setParameter("3000", forKey:IFlySpeechConstant.VAD_BOS());
            //网络等待时间
            self.iFlySpeechRecognizer.setParameter("20000", forKey:IFlySpeechConstant.NET_TIMEOUT());
            //设置采样率，推荐使用16K
            self.iFlySpeechRecognizer.setParameter("16000", forKey:IFlySpeechConstant.SAMPLE_RATE());
            //设置是否返回标点符号
            self.iFlySpeechRecognizer.setParameter("1", forKey:IFlySpeechConstant.ASR_PTT());
            //设置语言
            self.iFlySpeechRecognizer.setParameter("CHINESE", forKey:IFlySpeechConstant.LANGUAGE());
            
            self.iFlySpeechRecognizer.delegate = self
        }
        
        
    }
    
//    //数据持久化操作
//    func save() {
//        //var error: NSError?
//        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedObjectContext = appDelegate.managedObjectContext
//        
//        let entity =  NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
//        let noteToSave = NSManagedObject(entity: entity!,
//                                     insertIntoManagedObjectContext:managedObjectContext)
//        noteToSave.setValue(self.textView.text, forKey: "content")
//        noteToSave.setValue(false, forKey: "flag")
//        textView.text = ""
//        
//        //*************** just for test ************
//        let fetchRequest = NSFetchRequest(entityName:"Note")
//        do {
//            let fetchedResults =
//                try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
//            notes = fetchedResults
//            print(notes)
//        } catch {
//            print("Could not fetch")
//        }
//        //***************************************
//        
//    }
    
    

//****************IFlySpeechRecognizerDelegate实现*******************
    
    /**
     音量回调函数
     volume 0－30
     ****/
    func onVolumeChanged(volume: Int32) {
        
    }
    
    /**
     开始识别回调
     ****/
    func onBeginOfSpeech() {
    
    }
    
    /**
     停止录音回调
     ****/
    func onEndOfSpeech() {
        
    }
    
    
    /**
     听写结束回调（注：无论听写是否正确都会回调）
     error.errorCode =
     0     听写正确
     other 听写出错
     ****/
    func onError(errorCode: IFlySpeechError!) {
        
    }
    
    /**
     无界面，听写结果回调
     results：听写结果
     isLast：表示最后一次
     ****/
    func onResults(results: [AnyObject]!, isLast: Bool) {
        if results != nil {
            var rawResultString: String? = String()
            let resultDictionary = results![0] as! [String: AnyObject]
            for (key, _) in resultDictionary {
                rawResultString!.appendContentsOf(key)
            }
            let processedResultString = self.stringFromJson(rawResultString)
            self.textView!.text = self.textView!.text + processedResultString!
            self.note = self.textView!.text
        }
    }
    
    /**
     听写取消回调
     ****/
    func onCancel() {
        
    }
    
//****************DataHelper*******************
    
    /**
     解析听写json格式的数据
     ****/
    func stringFromJson(params: String?) -> String? {
        if params == nil {
            return nil
        }
    
        var tempStr: String? = String()
        var resultDic: NSDictionary?
        do {
            resultDic = try NSJSONSerialization.JSONObjectWithData((params!.dataUsingEncoding(NSUTF8StringEncoding))!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        }catch {}
       
        if  resultDic != nil {
            let wordArray = resultDic!.objectForKey("ws") as! NSArray
            for i in 0..<wordArray.count {
                let wsDic = wordArray.objectAtIndex(i) as! NSDictionary
                let cwArray = wsDic.objectForKey("cw") as! NSArray
                for j in 0..<cwArray.count {
                    let wDic = cwArray.objectAtIndex(j) as! NSDictionary
                    let str = wDic.objectForKey("w") as! String
                    tempStr!.appendContentsOf(str)
                }
                
            }
        }
        return tempStr
    }
    
}
