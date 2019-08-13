//
//  IMUICameraCell.swift
//  IMUIChat
//
//  Created by oshumini on 2017/3/9.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import Photos
import AVFoundation


private enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
}

private enum LivePhotoMode {
		case on
		case off
}


// TODO: Need to Restructure
@available(iOS 8.0, *)
class IMUICameraCell: UICollectionViewCell, IMUIFeatureCellProtocol {
  
  @IBOutlet weak var cameraView: IMUICameraView!
  
  open var cameraVC = IMUIHidenStatusViewController() // use to present full size mode viewcontroller
  var isFullScreenMode = false
  var isActivity = true
  var featureDelegate: IMUIFeatureViewDelegate?
  
  override func awakeFromNib() {
      super.awakeFromNib()
      cameraView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 253)
    
      cameraView.startRecordVideoCallback = {
        self.featureDelegate?.startRecordVideo()
      }
    
      cameraView.recordVideoCallback = {(path, duration) in
      self.featureDelegate?.didRecordVideo(with: path, durationTime: duration)
      if self.isFullScreenMode {
        self.shrinkDownScreen()
        self.isFullScreenMode = false
      }
    }
    
    cameraView.shootPictureCallback = { imageData in
      DispatchQueue.main.async {
        self.featureDelegate?.didShotPicture(with: imageData)
      }
      if self.isFullScreenMode {
        // Switch to main thread operation UI
        DispatchQueue.main.async {
            self.shrinkDownScreen()
        }
        self.isFullScreenMode = false
      }
    }
    
    cameraView.onClickFullSizeCallback = { btn in
        if self.isFullScreenMode {
          self.shrinkDownScreen()
          self.isFullScreenMode = false
          
        } else {
          self.setFullScreenMode()
          self.isFullScreenMode = true
          
        }
    }
  }
  
  func setFullScreenMode() {
    self.featureDelegate?.cameraFullScreen()
    let rootVC = UIApplication.shared.delegate?.window??.rootViewController
    self.cameraView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    self.cameraVC.view = self.cameraView
    DispatchQueue.main.async {
      rootVC?.present(self.cameraVC, animated: true, completion: {} )
    }
  }
  
  func shrinkDownScreen() {
    
    self.featureDelegate?.cameraRecoverScreen()
    DispatchQueue.main.async {
      self.cameraVC.dismiss(animated: false, completion: {
        print("\(self.contentView)")
        self.contentView.addSubview(self.cameraView)
        self.cameraView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 253)
      })
    }
    
  }
  
  func activateMedia() {
    isActivity = true
    self.cameraView?.activateMedia()
  }
  
  func inactivateMedia() {
    self.cameraView?.inactivateMedia()
  }
  
  @IBAction func clickToAdjustCameraViewSize(_ sender: Any) {
    let rootVC = UIApplication.shared.delegate?.window??.rootViewController
    let cameraVC = UIViewController()
    
    cameraVC.view.backgroundColor = UIColor.white
    cameraVC.view = cameraView
    
    rootVC?.present(cameraVC, animated: true, completion: {
    })
  }
}
