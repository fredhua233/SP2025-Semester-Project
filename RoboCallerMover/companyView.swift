import SwiftUI
import Supabase
import AVKit
import AVFoundation

struct CompanyView: View {
    let company: MovingCompany?
    let movingQueryID: Int
    let movingInquiryID: Int
    @State private var inquiry: MovingInquiry?
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var playerError: String?
    init ( company: MovingCompany?, movingQueryID: Int, movingInquiryID: Int, initialInquiry: MovingInquiry? = nil) {
        self.company = company
        self.movingQueryID = movingQueryID
        self.movingInquiryID = movingInquiryID
        _inquiry = State(initialValue: initialInquiry)
    }
    

    var body: some View {
        ScrollView { // Added ScrollView to enable scrolling
            VStack(alignment: .leading, spacing: 16) {
                
                if let company = company{
                    //companyHeader(company)
                    callToGetPriceButton(inquiry: inquiry)
                    coverImage()
                    ratingSection(company)
                    inquiryStatus(inquiry)
                } else {
                    Text("No company details available.")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle(company?.name ?? "Company Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            subscribeToRealtimeUpdates()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func companyHeader(_ company: MovingCompany) -> some View {
        Text(company.name)
            .font(.largeTitle)
            .bold()
            .padding(.top)
    }

    @ViewBuilder
    private func callToGetPriceButton(inquiry: MovingInquiry?) -> some View {
        if let inquiry = inquiry, !inquiry.in_progress && inquiry.price == -1 {
            Button(action: {
                makeCall()
            }) {
                Text("Call to Get Price")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("MovingBlue"))
                    .cornerRadius(10)
            }
        }
    }

    @ViewBuilder
    private func coverImage() -> some View {
        let defaultImageURL = "https://t4.ftcdn.net/jpg/02/30/62/35/360_F_230623592_cQY0YbsQb523d3b0yqVFupoOxIRGwtEO.jpg"
        let imageURL = company?.coverImage ?? defaultImageURL

        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9) // Resized to take almost the entire width
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
        }
    }

    @ViewBuilder
    private func ratingSection(_ company: MovingCompany) -> some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(company.rating) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            Text("(\(company.user_ratings_total))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func inquiryStatus(_ inquiry: MovingInquiry?) -> some View {
        if let inquiry = inquiry {
            if !inquiry.in_progress {
                Text("Please make the call to get moving details")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else if inquiry.in_progress && inquiry.price == -1 {
                Text("Call is in progress, please wait while we get your price.")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            } else if inquiry.in_progress && inquiry.price != -1 {
                Section(header: Text("Price").font(.headline)) {
                    Text("$\(inquiry.price ?? 0)")
                        .font(.title)
                        .bold()
                }

                Section(header: Text("Call Information").font(.headline)) {
                    Text("Duration: \(inquiry.call_duration ?? 0) minutes")
                        .font(.subheadline)
                    Text("Summary: \(inquiry.summary ?? "No summary available")")
                        .font(.subheadline)
                    Text("Full Transcript: \(inquiry.phone_call_transcript ?? "No transcript available")")
                        .font(.subheadline)
                }
                
                if let recordingUrl = inquiry.recording_url, !recordingUrl.isEmpty {
                    Section(header: Text("Recording").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Button(action: {
                                if isPlaying {
                                    // Pause playback
                                    player?.pause()
                                    isPlaying = false
                                } else {
                                    if player == nil {
                                        // First time playing or player was released
                                        if let url = URL(string: recordingUrl) {
                                            // Set up audio session
                                            do {
                                                try AVAudioSession.sharedInstance().setCategory(.playback)
                                                try AVAudioSession.sharedInstance().setActive(true)
                                            } catch {
                                                playerError = "Audio session error: \(error.localizedDescription)"
                                                return
                                            }
                                            
                                            player = AVPlayer(url: url)
                                            
                                            // Add observer for when playback ends
                                            NotificationCenter.default.addObserver(
                                                forName: .AVPlayerItemDidPlayToEndTime,
                                                object: player?.currentItem,
                                                queue: .main) { _ in
                                                    isPlaying = false
                                                }
                                        } else {
                                            playerError = "Invalid URL: \(recordingUrl)"
                                            return
                                        }
                                    }
                                    
                                    // Start playback
                                    player?.play()
                                    isPlaying = true
                                    playerError = nil
                                }
                            }) {
                                HStack {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title2)
                                    Text(isPlaying ? "Pause Recording" : "Play Recording")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                            }
                            
                            if isPlaying {
                                Text("Audio is playing...")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if let error = playerError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        } else {
            Text("Inquiry details are not available.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    private func updateInquiry() async {
        do {
            let response = try await supabase
                .from("moving_inquiry")
                .select("*")
                .eq("id", value: movingInquiryID)
                .single()
                .execute()

            let data = response.data  // Direct assignment, since data is non-optional
            
            let updatedInquiry = try JSONDecoder().decode(MovingInquiry.self, from: data)
            await MainActor.run {
                inquiry = updatedInquiry
            }
        } catch {
            print("Failed to update inquiry: \(error.localizedDescription)")
        }
    }

    private func subscribeToRealtimeUpdates() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await updateInquiry()
            }
        }
    }
    // MARK: - Make Call Function
    private func makeCall() {
        guard let inquiry = inquiry else {
            print("Inquiry is missing")
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/call_moving_companies/?moving_company_number=\(inquiry.phone_number)&moving_company_id=\(inquiry.moving_company_id)&moving_query_id=\(inquiry.moving_query_id)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making call: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }

            // Update the in_progress column in the moving_inquiry table
            Task {
                do {
                    let _ = try await supabase
                        .from("moving_inquiry")
                        .update(["in_progress": true])
                        .eq("id", value: inquiry.id)
                        .execute()
                } catch {
                    print("Error updating in_progress column: \(error)")
                }
            }
        }

        task.resume()

        // Call this function to update the inquiry status after making the call
        Task {
            await updateInquiry()
        }
    }
}

// Audio player delegate to handle playback completion
class PlaybackDelegate: NSObject, AVAudioPlayerDelegate {
    var onCompletion: () -> Void
    
    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onCompletion()
    }
}

// Custom SwiftUI view to wrap AVPlayerViewController
struct PlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.player?.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
