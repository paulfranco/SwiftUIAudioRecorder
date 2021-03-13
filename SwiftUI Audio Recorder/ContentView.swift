//
//  ContentView.swift
//  SwiftUI Audio Recorder
//
//  Created by Paul Franco on 3/12/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}


struct Home : View {
    @State var record = false
    // creating instance for recording
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert = false
    // Fetch audions
    @State var audios: [URL] = []
    
    var body: some View {
    
        NavigationView {
            VStack {
                List(self.audios, id: \.self) { i in
                    Text(i.relativeString)
                }
                
                Button(action: {
                    do {
                        if self.record {
                            // already recording need to stop and save
                            self.recorder.stop()
                            self.record.toggle()
                            // updating data for every recording
                            self.getAudios()
                            return
                        }
                        // store audio in document directory
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.appendingPathComponent("myRcd\(self.audios.count + 1).m4a")
                        
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        
                        // Initialize
                        self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                        
                        self.recorder.record()
                        self.record.toggle()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                        if self.record {
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 85, height: 85)
                        }
                    }
                }
                .padding(.vertical, 25)
            }
            .navigationTitle("Record Audio")
        }
        .alert(isPresented: self.$alert, content: {
                Alert(title: Text("Error"), message: Text("Enable Microphone Access"))
        })
        .onAppear {
            do {
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.playAndRecord)
                
                // we require microphone usage permission in info.plist
                self.session.requestRecordPermission { (status) in
                    if !status {
                        // error msg
                        self.alert.toggle()
                    } else {
                        // if permission granted means fetching all data
                        self.getAudios()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    func getAudios() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // fetch all data from document directory
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            // remove all audions before updating
            self.audios.removeAll()
            
            for i in result {
                self.audios.append(i)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
