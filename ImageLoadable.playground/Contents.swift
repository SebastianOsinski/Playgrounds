import PlaygroundSupport
import SwiftUI
import Combine

protocol ImageLoadable {
    func loadImage() -> AnyPublisher<UIImage, Error>
    
    func equals(_ other: ImageLoadable) -> Bool
}

extension ImageLoadable where Self: Equatable {
    func equals(_ other: ImageLoadable) -> Bool {
        return other as? Self == self
    }
}

extension URL: ImageLoadable {
    enum ImageLoadingError: Error {
        case incorrectData
    }
    
    func loadImage() -> AnyPublisher<UIImage, Error> {
        URLSession
            .shared
            .dataTaskPublisher(for: self)
            .tryMap { data, _ in
                guard let image = UIImage(data: data) else {
                    throw ImageLoadingError.incorrectData
                }
                
                return image
            }
            .eraseToAnyPublisher()
    }
}

extension UIImage: ImageLoadable {
    func loadImage() -> AnyPublisher<UIImage, Error> {
        return Just(self)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

final class ImageLoader: BindableObject {
    let willChange = PassthroughSubject<(), Never>()
    
    private let loadable: ImageLoadable
    
    private(set) var image: UIImage? {
        willSet {
            if newValue != nil {
                willChange.send()
            }
        }
    }
    
    private var cancellable: AnyCancellable?
    
    init(loadable: ImageLoadable) {
        self.loadable = loadable
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        cancellable = loadable
            .loadImage()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    self?.image = image
                }
            )
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct ImageLoadingView: View {
    @ObjectBinding var imageLoader: ImageLoader
    
    init(image: ImageLoadable) {
        imageLoader = ImageLoader(loadable: image)
    }
    
    var body: some View {
        ZStack {
            if imageLoader.image != nil {
                Image(uiImage: imageLoader.image!)
                    .resizable()
            }
        }
        .onAppear(perform: imageLoader.load)
        .onDisappear(perform: imageLoader.cancel)
    }
}

struct AnyImageLoadable<WhenDecodedLoadable: ImageLoadable & Decodable>: ImageLoadable, Equatable, Decodable {
    private let loadable: ImageLoadable
    
    init(_ loadable: ImageLoadable) {
        self.loadable = loadable
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        loadable = try container.decode(WhenDecodedLoadable.self)
    }
    
    func loadImage() -> AnyPublisher<UIImage, Error> {
        return loadable.loadImage()
    }
    
    static func ==(lhs: AnyImageLoadable, rhs: AnyImageLoadable) -> Bool {
        return lhs.loadable.equals(rhs.loadable)
    }
}

extension ImageLoadable {
    func any<T>() -> AnyImageLoadable<T> {
        return AnyImageLoadable<T>(self)
    }
}

struct Pet: Equatable, Decodable {
    let name: String
    let age: Int
    let image: AnyImageLoadable<URL>
}

// Decoding Pet:

let json = #"""
{
    "name": "Dot",
    "age": 2,
    "image": "https://cdn.pixabay.com/photo/2014/03/29/09/17/cat-300572_1280.jpg"
}
"""#

let jsonData = json.data(using: .utf8)!
let decodedPet = try! JSONDecoder().decode(Pet.self, from: jsonData)

print(decodedPet)

// Creating Pet with image from resources:

let imageLiteral = UIImage(imageLiteralResourceName: "cat.jpg")

let createdPet = Pet(
    name: "Cat",
    age: 1,
    image: imageLiteral.any()
)

PlaygroundPage.current.liveView = UIHostingController(rootView:
    ImageLoadingView(
        image: decodedPet.image
//        image: createdPet.image
    ).aspectRatio(contentMode: .fit)
)

// Filler type to pass into `AnyImageLoadable` when decodability is not needed, only equatability
enum NeverImageLoadable: ImageLoadable, Hashable, Decodable {
    enum Error: Swift.Error {
        case neverDecoding
        case neverLoad
    }
    
    init(from decoder: Decoder) throws {
        throw Error.neverDecoding
    }
    
    func loadImage() -> AnyPublisher<UIImage, Swift.Error> {
        return Fail(error: Error.neverLoad)
            .eraseToAnyPublisher()
    }
}

typealias EqImageLoadable = AnyImageLoadable<NeverImageLoadable>
