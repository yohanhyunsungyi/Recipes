# Yohan's Recipes

## 1. Summary

#### Figma Design 
https://www.figma.com/design/bfQRQnHxklgU6Hkj8CknYh/Untitled?node-id=0-1&t=lUqb9bAWJkfCEapg-1

### Architecture

<img width="1395" alt="Screenshot 2025-03-03 at 2 24 30 AM" src="https://github.com/user-attachments/assets/fa15ba78-5668-452a-a3d4-ce89ebaf5312" />

#### View
- `HomeView`: Main view with search, filtering, and grid layout
- `DetailView`: Detailed recipe view with sharing options
- `RecipeCard`: Reusable card component
- `RecipeImage`: Async image loading with placeholder support

#### ViewModel
- `RecipeViewModel`: Handles business logic, state management, and user interactions

#### Utiliteis
- `ImageLoader`: Combines local and remote image loading
- `LocalImageLoader`: Interface for local image caching operations
- `RemoteImageLoader`: Handles network image fetching
- `ImageCache`: Thread-safe memory caching using `NSCache`
- `RecipeLoader`: Manages recipe data fetching

### Features
| Dynamic Recipe Grid | Refresh Recipes | Suffle Recipes |
|---|---|---|
| ![grid](https://github.com/user-attachments/assets/c76bf512-974d-4522-86a0-6f43dc30ffe8) https://github.com/user-attachments/assets/74a898f5-97af-43d3-ac74-0acc411866df | ![Refresh](https://github.com/user-attachments/assets/6cd9eca7-e9a1-4073-ad30-2e32dae7f19d) https://github.com/user-attachments/assets/451ae315-fef9-4841-9e0b-02c689d7aec5 | ![Shuffle](https://github.com/user-attachments/assets/b78bf28b-1c2b-4a8d-85a9-afc4fe4ddb56) https://github.com/user-attachments/assets/6f3c7ebf-3624-4349-b747-1dc9b71d0ede |

| Favorites System | Search Recipes | Detail View |
|---|---|---|
| ![Favorites](https://github.com/user-attachments/assets/834fa47c-5bb9-410e-8d1a-394e2fe05d54) https://github.com/user-attachments/assets/5c7e4da4-5cf1-42dd-8830-53a5c992110b | ![Search](https://github.com/user-attachments/assets/82570798-858f-4e68-b547-84d06c5676c9) https://github.com/user-attachments/assets/19dca29c-7359-4c93-b3c9-13eee172c31b | ![DetailView](https://github.com/user-attachments/assets/33156341-cef7-4aa7-a5c8-9d6757b33dd7)d https://github.com/user-attachments/assets/ea9c5ee1-d0cd-463d-b232-9c6dfd7991ab |

#### Loading Screens
| Loading Recipes | Loading Images | 
|---|---|
| <img width="451" alt="RecipesLoading" src="https://github.com/user-attachments/assets/8f6d2e9b-d7cb-4a6e-ad16-23a97d076dac" /> | <img width="447" alt="ImageLoading" src="https://github.com/user-attachments/assets/29db656a-8d94-4ffb-803b-73806a67d941" /> | 

#### Error Screens
| No Search Result | No Search Result within Favorite | No Favorites | Malformed Data Response | Empty Data Response |
|---|---|---|---|---|
| <img width="457" alt="noSearchResult" src="https://github.com/user-attachments/assets/90649c38-1f93-488d-a9fc-664fae36ce63" /> | <img width="455" alt="noSearchResultinFavorite" src="https://github.com/user-attachments/assets/1dc78e18-869a-4d19-8d33-6604ab31a387" /> | <img width="438" alt="noFavorite" src="https://github.com/user-attachments/assets/9f48007a-ce63-42ec-9136-8f8a5723de03" /> | <img width="446" alt="Malformed" src="https://github.com/user-attachments/assets/7eff6cf2-89b4-424d-842f-87adeeea33ff" /> | <img width="450" alt="EmptyResponse" src="https://github.com/user-attachments/assets/0c4de032-7123-4460-b2a9-c20d8d143bb1" /> |

## 2. Focus Areas

**Image Management System**: ImageLoader orchestrates the loading process by coordinating between local cache and remote fetching.
1. Check memory cache via `LocalImageLoader`
2. If cache miss, fetch from network via `RemoteImageLoader`
3. Store successful network loads in memory cache
4. Publish results to SwiftUI view
   
## 3. Trade-offs and Decisions

**Filtered Recipe Array in View**: The filtered recipe array is stored in the view layer rather than the ViewModel. This decision was made to:
  - Maintain better separation of concerns where the ViewModel manages the source of truth (original recipes)
  - Allow for more flexible and independent filtering logic
  - Reduce unnecessary state synchronization between the ViewModel and views

## 4. Weakest Part of the Project

#### Task Management and Race Conditions
- Current task management in the project needs more detailed implementation, especially regarding cancellation
- With multiple features and concurrent operations, there's a potential risk of race conditions
- Future improvements should include more robust task lifecycle management and better synchronization mechanisms

#### Memory Management
- The current image caching system needs improvements for scalability
- Although the API currently returns a manageable number of images, the system could face memory pressure with a larger dataset

## 5. Time Spent: 
4 days
