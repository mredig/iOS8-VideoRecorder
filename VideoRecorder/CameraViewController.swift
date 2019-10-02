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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		captureSession.startRunning()
		print("start running")
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		captureSession.stopRunning()
		print("stop running")
	}

	private func setupCamera() {
		// get camera
		let camera = bestCamera()
		// set up settings
		guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("can't crette input") }

		guard captureSession.canAddInput(cameraInput) else {
			fatalError("Cant add input")
		}
		captureSession.addInput(cameraInput)

		if captureSession.canSetSessionPreset(.hd1920x1080) {
			captureSession.sessionPreset = .hd1920x1080
		}

		captureSession.commitConfiguration()

		cameraView.session = captureSession
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

