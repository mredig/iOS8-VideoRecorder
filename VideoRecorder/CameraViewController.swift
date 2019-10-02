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

	private var player: AVPlayer!

	@IBOutlet var recordButton: UIButton!
	@IBOutlet var cameraView: CameraPreviewView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		setupCamera()
		updateViews()

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
		view.addGestureRecognizer(tapGesture)
	}

	@objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
		switch tapGesture.state {
		case .ended:
			print("tapped!")
			replayVideo()
		default:
			print("handle other states: \(tapGesture.state)")
		}
	}

	func replayVideo() {
		if let player = player {
			player.seek(to: CMTime.zero)
			player.play()
		}
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

		// input audio
		let microphone = audio()
		guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
			fatalError("cant create input from mic")
		}

		guard captureSession.canAddInput(audioInput) else {
			fatalError("can't add audio input")
		}
		captureSession.addInput(audioInput)

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

	private func audio() -> AVCaptureDevice {
//		if let device = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .back) {
//			return device
//		}

		if let device = AVCaptureDevice.default(for: .audio) {
			return device
		}
		fatalError("no audio device")
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

	func playMovie(url: URL) {
		player = AVPlayer(url: url)

		let playerLayer = AVPlayerLayer(player: player)
		var topRect = self.view.bounds
		topRect.size.width /= 4
		topRect.size.height /= 4
		topRect.origin.y = view.layoutMargins.top

		playerLayer.frame = topRect
		view.layer.addSublayer(playerLayer)

		player.play()
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
			self.playMovie(url: outputFileURL)
		}
	}
}
