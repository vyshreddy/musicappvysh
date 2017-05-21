

import UIKit

import AVFoundation
import MediaPlayer
class TestMusicPlayer: NSObject {
 
    let avQueuePlayer:AVQueuePlayer = AVQueuePlayer()
    
    /**
    Initialises the audio session
    */
    class func initSession() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(TestMusicPlayer.audioSessionInterrupted(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            let _ = try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("an error occurred when audio session category.\n \(error)")
        }
    }
    
    /**
    Pause music
    */
    func pause() {
        avQueuePlayer.pause()
    }
    
    /**
    Play music
    */
    func play() {
        avQueuePlayer.play()
    }
    
    func playSongWithId(_ songId:NSNumber, title:String, artist:String) {
        MusicQuery().queryForSongWithId(songId, completionHandler: {[weak self] (result:MPMediaItem?) -> Void in
            if let nonNilResult = result {
                if let assetUrl = nonNilResult.value(forProperty:MPMediaItemPropertyAssetURL) as? URL {
                    let avSongItem = AVPlayerItem(url: assetUrl)
                    self!.avQueuePlayer.insert(avSongItem, after: nil)
                    self!.play()
                    //display now playing info on control center
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: title, MPMediaItemPropertyArtist: artist]
                } else {
                    print("assetURL for song \(songId) does not exist")
                }
            }
        })
        
    }
    
    func songIsAvailable(songId:NSNumber, completion:((Bool)->Void)? = nil)
    {
        MusicQuery().queryForSongWithId(songId, completionHandler: {(result:MPMediaItem?) -> Void in
            if let nonNilResult = result {
                if let _ = nonNilResult.value(forProperty:MPMediaItemPropertyAssetURL) as? URL {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        })
    }

    
    //MARK: - Notifications
    class func audioSessionInterrupted(_ notification:Notification)
    {
        print("interruption received: \(notification)")
    }
    
    //response to remote control events
    
    func remoteControlReceivedWithEvent(_ receivedEvent:UIEvent)  {
        if (receivedEvent.type == .remoteControl) {
            switch receivedEvent.subtype {
            case .remoteControlTogglePlayPause:
                if avQueuePlayer.rate > 0.0 {
                    pause()
                } else {
                    play()
                }
            case .remoteControlPlay:
                play()
            case .remoteControlPause:
                pause()
            default:
                print("received sub type \(receivedEvent.subtype) Ignoring")
            }
        }
    }
    
    

}
