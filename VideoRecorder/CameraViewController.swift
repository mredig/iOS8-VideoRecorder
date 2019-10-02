//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

	lazy private var captureSession = AVCaptureSession()

	@IBOutlet var recordButton: UIButton!
	@IBOutlet var cameraView: CameraPreviewView!


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		setupCamera()
	}

	private func setupCamera() {
		// get camera
		let camera = bestCamera()
		// set up settings
		// set capture session on camera view
	}

	private func bestCamera() -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			return device
		}

		fatalError("No cameras")
	}

	@IBAction func recordButtonPressed(_ sender: Any) {

	}
}

