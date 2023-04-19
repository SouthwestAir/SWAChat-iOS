//
//  MockUsernameGenerator.swift
//  ChatDemo
//
//  Designed to create a random, generic sounding username and avatar "icon"
//  For use with the chat demo to quickly create multiple users

import UIKit

class MockUsernameGenerator {
    static let shared = MockUsernameGenerator()
    
    let adjectives = ["adaptable","adept","adorable","affectionate","agreeable","alluring","amazing","ambitious","amiable","ample","amusing","approachable","awesome","awesome","beautiful","blithesome","bountiful","brave","brave","breathtaking","bright","brilliant","calm","capable","captivating","caring","charming","cheerful","clever","competitive","confident","considerate","courageous","creative","dazzling","dependable","determined","devoted","diligent","diplomatic","dynamic","educated","efficient","elegant","enchanting","energetic","energetic","engaging","excellent","excited","fabulous","fair","faithful","fantastic","fantastic","favorable","fearless","flexible","focused","fortuitous","frank","friendly","friendly","friendly","fun","funny","generous","generous","giving","gleaming","glimmering","glistening","glittering","glowing","glowing","good","gorgeous","gregarious","happy","happy","happy","hardworking","hardworking","heartwarming","helpful","hilarious","honest","humorous","imaginative","incredible","independent","inquisitive","insightful","kind","knowledgeable","likable","lovable","lovely","loving","loyal","loyal","lustrous","magnificent","marvelous","mirthful","moving","nice","optimistic","organized","outstanding","passionate","patient","perfect","persistent","personable","philosophical","plucky","polite","polite","polite","powerful","productive","proficient","propitious","qualified","quick","quiet","ravishing","relaxed","remarkable","resourceful","responsible","romantic","rousing","sensible","sensible","sincere","sleek","sparkling","spectacular","spellbinding","splendid","stellar","stunning","stupendous","sturdy","super","technological","thoughtful","truthful","truthful","twinkling","understanding","unique","upbeat","vibrant","vivacious","vivid","willing","wise","wonderful","wondrous","zestful"]
    
    let avatar = ["🙈","🙉","🙊","🐵","🐒","🦍","🦧","🐶","🐕","🦮","🐕‍🦺","🐩","🐺","🦊","🦝","🐱","🐈","🐈‍⬛","🦁","🐯","🐅","🐆","🐴","🐎","🦄","🦓","🦌","🦬","🐮","🐂","🐃","🐄","🐷","🐖","🐗","🐏","🐑","🐐","🐪","🐫","🦙","🦒","🐘","🦣","🦏","🦛","🐭","🐁","🐹","🐰","🐇","🐿️","🦫","🦔","🦇","🐻","🐻‍❄️","🐨","🐼","🦥","🦦","🦨","🦘","🦡","🐾","🦃","🐔","🐓","🐣","🐤","🐦","🐦‍⬛","🐧","🕊️","🦅","🦆","🦢","🦉","🪶","🦩","🦚","🦜","🐸","🐊","🐢","🦎","🐍","🐲","🐉","🦕","🦖","🐳","🐋","🐬","🦭","🐟","🐠","🐡","🦈","🐙","🐚","🪸","🐌","🦋","🐛","🐜","🐝","🪲","🐞","🦗","🕷️","🕸️","🦂","🦟","💐","🌸","🪷","🌹","🌺","🌻","🌼","🌷","🌱","🪴","🌲","🌳","🌴","🌵","🌾","☘️","🍀","🍁","🪺","🍄","🌰","🦀","🦞","🦐","🦑","☀️","⭐","☁️","🌈","☂️","❄️","☃️","🎄"]
    
    let nouns = ["MonkeySee","MonkeyHear","MonkeySpeak","MonkeyFace","Monkey","Gorilla","Orangutan","Puppy","Dog","GuideDog","ServiceDog","Poodle","Wolf","Fox","Raccoon","Kitty","Cat","BlackCat","Lion","TigerFace","Tiger","Leopard","Horse","HorseRun","Unicorn","Zebra","Deer","Bison","Cow","Ox","Buffalo","CowStanding","Pig","PigStanding","Boar","Ram","Ewe","Goat","Dromedary","Camel","Llama","Giraffe","Elephant","Mammoth","Rhinoceros","Hippopotamus","MouseFace","Mouse","Hamster","RabbitFace","Rabbit","Chipmunk","Beaver","Hedgehog","Bat","Bear","PolarBear","Koala","Panda","Sloth","Otter","Skunk","Kangaroo","Badger","Paws","Turkey","Chicken","Rooster","HatchingChick","BabyChick","Bird","BlackBird","Penguin","Dove","Eagle","Duck","Swan","Owl","Feather","Flamingo","Peacock","Parrot","Frog","Crocodile","Turtle","Lizard","Snake","DragonFace","Dragon","Sauropod","TRex","CuteWhale","Whale","Dolphin","Seal","Fish","TropicalFish","Blowfish","Shark","Octopus","SpiralShell","Coral","Snail","Butterfly","Caterpillar","Ant","Honeybee","Beetle","LadyBug","Cricket","Spider","Web","Scorpion","Mosquito","Bouquet","CherryBlossom","Lotus","Rose","Hibiscus","Sunflower","Blossom","Tulip","Seedling","Plant","Evergreen","Tree","PalmTree","Cactus","Rice","Shamrock","Clover","MapleLeaf","Nest","Mushroom","Chestnut","Crab","Lobster","Shrimp","Squid","Sun","Star","Cloud","Rainbow","Umbrella","Snow","Snowman","ChristmasTree"]
    
    var currentAvatar: Int = 0
    
    func generateAvatar() -> String {
        currentAvatar = Int.random(in: 0..<avatar.count)
        return avatar[currentAvatar]
    }

    func generateUsername() -> String {
        let adjectiveIndex = Int.random(in: 0..<adjectives.count)
        let nounIndex = currentAvatar
        
        let username = adjectives[adjectiveIndex].capitalized + nouns[nounIndex]
        return username
    }
    
}
