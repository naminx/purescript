module Database.Mock where

import Prelude

import Data.Array (snoc, filter)
import Data.Maybe (Maybe(..))
import Database.Types (Customer, DatabaseInterface)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref

-- | Create a mock database interface using an in-memory Ref
createMockDatabase :: forall m. MonadEffect m => Effect (DatabaseInterface m)
createMockDatabase = do
  -- Initialize with some test customers
  customersRef <- Ref.new initialCustomers
  nextIdRef <- Ref.new 102 -- Next available ID (after 101 initial customers)
  
  pure
    { getAllCustomers: liftEffect $ Ref.read customersRef
    
    , addNewCustomer: \name -> liftEffect do
        customers <- Ref.read customersRef
        nextId <- Ref.read nextIdRef
        let newCustomer = { id: nextId, name }
        Ref.write (snoc customers newCustomer) customersRef
        Ref.write (nextId + 1) nextIdRef
    
    , updateCustomerName: \{ id, name } -> liftEffect do
        customers <- Ref.read customersRef
        let updatedCustomers = map (\c -> if c.id == id then c { name = name } else c) customers
        Ref.write updatedCustomers customersRef
    
    , deleteCustomer: \id -> liftEffect do
        customers <- Ref.read customersRef
        let filteredCustomers = filter (\c -> c.id /= id) customers
        Ref.write filteredCustomers customersRef
    }

-- | Initial test data - 100 customers
initialCustomers :: Array Customer
initialCustomers =
  [ { id: 1, name: "Alice Johnson" }
  , { id: 2, name: "Bob Smith" }
  , { id: 3, name: "Charlie Brown" }
  , { id: 4, name: "Diana Prince" }
  , { id: 5, name: "Edward Norton" }
  , { id: 6, name: "Fiona Apple" }
  , { id: 7, name: "George Wilson" }
  , { id: 8, name: "Hannah Montana" }
  , { id: 9, name: "Isaac Newton" }
  , { id: 10, name: "Julia Roberts" }
  , { id: 11, name: "Kevin Hart" }
  , { id: 12, name: "Laura Palmer" }
  , { id: 13, name: "Michael Scott" }
  , { id: 14, name: "Nancy Drew" }
  , { id: 15, name: "Oliver Twist" }
  , { id: 16, name: "Patricia Moore" }
  , { id: 17, name: "Quincy Jones" }
  , { id: 18, name: "Rachel Green" }
  , { id: 19, name: "Samuel Jackson" }
  , { id: 20, name: "Tina Turner" }
  , { id: 21, name: "Uma Thurman" }
  , { id: 22, name: "Victor Hugo" }
  , { id: 23, name: "Wendy Williams" }
  , { id: 24, name: "Xavier Woods" }
  , { id: 25, name: "Yolanda Adams" }
  , { id: 26, name: "Zachary Taylor" }
  , { id: 27, name: "Amanda Bynes" }
  , { id: 28, name: "Brandon Lee" }
  , { id: 29, name: "Catherine Zeta" }
  , { id: 30, name: "Daniel Craig" }
  , { id: 31, name: "Emma Watson" }
  , { id: 32, name: "Frank Sinatra" }
  , { id: 33, name: "Grace Kelly" }
  , { id: 34, name: "Henry Ford" }
  , { id: 35, name: "Iris West" }
  , { id: 36, name: "Jack Ryan" }
  , { id: 37, name: "Karen Page" }
  , { id: 38, name: "Leonard Cohen" }
  , { id: 39, name: "Monica Geller" }
  , { id: 40, name: "Nathan Drake" }
  , { id: 41, name: "Olivia Pope" }
  , { id: 42, name: "Peter Parker" }
  , { id: 43, name: "Quinn Fabray" }
  , { id: 44, name: "Ross Geller" }
  , { id: 45, name: "Sarah Connor" }
  , { id: 46, name: "Tony Stark" }
  , { id: 47, name: "Ursula Buffay" }
  , { id: 48, name: "Vincent Vega" }
  , { id: 49, name: "Walter White" }
  , { id: 50, name: "Xena Warrior" }
  , { id: 51, name: "Yvonne Strahovski" }
  , { id: 52, name: "Zoe Saldana" }
  , { id: 53, name: "Aaron Paul" }
  , { id: 54, name: "Bella Swan" }
  , { id: 55, name: "Clark Kent" }
  , { id: 56, name: "Daenerys Targaryen" }
  , { id: 57, name: "Ethan Hunt" }
  , { id: 58, name: "Felicity Smoak" }
  , { id: 59, name: "Gandalf Grey" }
  , { id: 60, name: "Hermione Granger" }
  , { id: 61, name: "Indiana Jones" }
  , { id: 62, name: "Jessica Jones" }
  , { id: 63, name: "Katniss Everdeen" }
  , { id: 64, name: "Luke Skywalker" }
  , { id: 65, name: "Marty McFly" }
  , { id: 66, name: "Neo Anderson" }
  , { id: 67, name: "Optimus Prime" }
  , { id: 68, name: "Princess Leia" }
  , { id: 69, name: "Quentin Tarantino" }
  , { id: 70, name: "Rick Grimes" }
  , { id: 71, name: "Sherlock Holmes" }
  , { id: 72, name: "Thor Odinson" }
  , { id: 73, name: "Ulysses Grant" }
  , { id: 74, name: "Violet Baudelaire" }
  , { id: 75, name: "Wade Wilson" }
  , { id: 76, name: "Xander Harris" }
  , { id: 77, name: "Yoda Master" }
  , { id: 78, name: "Zelda Princess" }
  , { id: 79, name: "Arthur Dent" }
  , { id: 80, name: "Bruce Wayne" }
  , { id: 81, name: "Carol Danvers" }
  , { id: 82, name: "David Bowie" }
  , { id: 83, name: "Ellen Ripley" }
  , { id: 84, name: "Frodo Baggins" }
  , { id: 85, name: "Gwen Stacy" }
  , { id: 86, name: "Harry Potter" }
  , { id: 87, name: "Ilsa Lund" }
  , { id: 88, name: "James Bond" }
  , { id: 89, name: "Kara Danvers" }
  , { id: 90, name: "Lara Croft" }
  , { id: 91, name: "Mary Poppins" }
  , { id: 92, name: "Nick Fury" }
  , { id: 93, name: "Obi-Wan Kenobi" }
  , { id: 94, name: "Phoebe Buffay" }
  , { id: 95, name: "Qui-Gon Jinn" }
  , { id: 96, name: "Rey Skywalker" }
  , { id: 97, name: "Steve Rogers" }
  , { id: 98, name: "Trinity Matrix" }
  , { id: 99, name: "Uhura Nyota" }
  , { id: 100, name: "Vito Corleone" }
  , { id: 101, name: "The Association for Overseas Technical Cooperation and Sustainable Partnerships (AOTS)" }
  ]
