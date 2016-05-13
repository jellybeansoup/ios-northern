//
//  ViewController.swift
//  Northern
//
//  Created by Daniel Farrelly on 12/05/2016.
//  Copyright © 2016 JellyStyle Media. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()

	let motionManager = CMMotionManager()

	@IBOutlet var disk: UIImageView?

	@IBOutlet var container: UIView?

	@IBOutlet var labels: [UILabel]?

	@IBOutlet var headingLabel: UILabel?

	@IBOutlet var debugLabel: UILabel?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.locationManager.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		self.locationManager.startUpdatingHeading()

		self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { motion, error in
			guard let attitude = motion?.attitude else {
				return
			}

			let roll = CGFloat(attitude.roll)
			let pitch = CGFloat(attitude.pitch)
			let yaw = self.heading ?? 0

			var diskTransform = CATransform3DIdentity
			diskTransform.m34 = 1.0/500.0
			diskTransform = CATransform3DRotate(diskTransform, roll, 0, 1, 0)
			diskTransform = CATransform3DRotate(diskTransform, pitch, -1, 0, 0)
			diskTransform = CATransform3DRotate(diskTransform, yaw, 0, 0, 1)
			self.disk?.layer.transform = diskTransform
			self.container?.layer.transform = diskTransform

			var labelTransform = CATransform3DIdentity
			labelTransform.m34 = 1.0/500.0
			labelTransform = CATransform3DRotate(labelTransform, yaw, 0, 0, -1)
			if abs(roll) > CGFloat(M_PI_2) {
				labelTransform = CATransform3DRotate(labelTransform, CGFloat(M_PI), 0, -1, 0)
			}
			for label in self.labels ?? [] {
				label.layer.transform = labelTransform
			}
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		self.locationManager.stopUpdatingHeading()
		self.motionManager.stopDeviceMotionUpdates()
	}

	var heading: CGFloat? = nil

	func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		guard newHeading.headingAccuracy > 0 else { return }

		let magnetic = newHeading.magneticHeading

		let readable = magnetic > 180.5 ? magnetic - 360 : magnetic
		self.headingLabel?.text = "\(Int(round(readable)))"

		let y = CGFloat( 0 - (M_PI) * (readable/180) )
		self.heading = y
	}

}

