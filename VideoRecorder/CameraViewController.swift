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

	/// would be best to put this in a wrapper for better mvc
	lazy private var fileOutput = AVCaptureMovieFileOutput()

	@IBOutlet var recordButton: UIButton!
	@IBOutlet var cameraView: CameraPreviewView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		setupCamera()
		updateViews()
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

		// input
		guard captureSession.canAddInput(cameraInput) else {
			fatalError("Cant add input")
		}
		captureSession.addInput(cameraInput)

		if captureSession.canSetSessionPreset(.hd1920x1080) {
			captureSession.sessionPreset = .hd1920x1080
		}

		//output
		guard captureSession.canAddOutput(fileOutput) else {
			fatalError("Can't save to file")
		}
		captureSession.addOutput(fileOutput)

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
		record()
	}

	func record() {
		if fileOutput.isRecording {
			fileOutput.stopRecording()
		} else {
			fileOutput.startRecording(to: newTempURL(withFileExtension: "mov"), recordingDelegate: self)
		}

		let files = try? FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
		print(files)
	}

	private func updateViews() {
		recordButton.isSelected = fileOutput.isRecording

		if recordButton.isSelected {
			recordButton.tintColor = .black
		} else {
			recordButton.tintColor = .red
		}
	}

	private func newTempURL(withFileExtension fileExtension: String? = nil) -> URL {
		let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
		let name = UUID().uuidString
		let tempFile = tempDir.appendingPathComponent(name).appendingPathExtension(fileExtension ?? "")

		return tempFile
	}
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
	func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
		DispatchQueue.main.async {
			self.updateViews()
		}
	}

	func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		DispatchQueue.main.async {
			self.updateViews()
		}
	}
}
