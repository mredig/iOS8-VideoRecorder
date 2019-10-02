//
//  ViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// TODO: get permission
		requestCameraPermission()
	}

	private func requestCameraPermission() {
		// TODO: get permission: show cam if we have it
		// TODO: error conditions with lack of permission
		let status = AVCaptureDevice.authorizationStatus(for: .video)

		switch status {
		case .notDetermined:
			// we have not asked yet
			requestCameraAccess()
		case .restricted:
			// parental controls limit
			fatalError("Please inform user they can't use app cuz their parents suck")
		case .denied:
			// user set
			fatalError("Please inform user they can't use app - tell them to enable in settings")
		case .authorized:
			showCamera()
		@unknown default:
			break
		}
	}

	private func requestCameraAccess() {
		AVCaptureDevice.requestAccess(for: .video) { granted in
			if granted == false {
				fatalError("User said no")
			} else {
				DispatchQueue.main.async {
					self.showCamera()
				}
			}
		}
	}
	
	private func showCamera() {
		performSegue(withIdentifier: "ShowCamera", sender: self)
	}
}
