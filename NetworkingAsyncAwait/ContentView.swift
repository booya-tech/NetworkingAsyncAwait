//
//  ContentView.swift
//  NetworkingAsyncAwait
//
//  Created by Panachai Sulsaksakul on 8/21/24.
//

import SwiftUI

//Steps to approach
//Step 1: Build Dummy UI
//Step 2: Create Model
//Step 3: Write Networking
//Step 4: Connect it

struct ContentView: View {
    @State var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 200)
            } placeholder: {
                Circle()
            }
            
            Text(user?.login ?? "Username Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio Placeholder")
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalid URL")
            } catch GHError.invalidResponse {
                print("invalid Response")
            } catch GHError.invalidData {
                print("invalid Data")
            } catch {
                print("unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/booya-tech"
        
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHError.invalidResponse }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
        
    }
}

#Preview {
    ContentView()
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct GitHubUser: Codable {
    var login: String
    var avatarUrl: String
    var bio: String
}
