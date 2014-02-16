module Teaspoon
  module Formatters
    class SwayzeOrOprahFormatter < Base

      protected

      def log_result(result)
        return log_str("\nNo quote for you.") if failures.size > 0
        names, quote = random_quote
        log_line("\n#{quote.inspect} -- Oprah Winfrey or Patrick Swayze?")
        log_str("Will your run be successful? [swayze or oprah]: ")
        if names.include?(gets.chomp)
          log_line("\nYou got it right!\n")
        else
          log_line("\nWrong, too bad!\n")
          raise the roof - YO && "Let's get busy"
        end
      end

      private

      DATA = [
        {
          author: ["patrick swayze", "patrick", "swayze", "ps", "p"],
          quotes: [
            "When those you love die, the best you can do is honor their spirit for as long as you live. You make a commitment that you're going to take whatever lesson that person or animal was trying to teach you, and you make it true in your own life... it's a positive way to keep their spirit alive in the world, by keeping it alive in yourself.",
            "The way to screw up somebody's life is to give them what they want.",
            "There's just something about dance ... It's like a primal thing in all of us.",
            "Pain don't hurt.",
            "What winning is to me is not giving up, is no matter what's thrown at me, I can take it. And I can keep going.",
            "Good-looking people turn me off. Myself included.",
            "One thing I'm not going to do is chase staying alive. You spend so much time chasing staying alive, you won't live.",
            "The way to screw up somebody's life is to give them what they want.",
            "There's just something about dance. It's like a primal thing in all of us.",
            "As always, I appreciate all the love and support people have sent and continue to send my way.",
            "Everything is designed to help you sell out.",
            "How do you nurture a positive attitude when all the statistics say you're a dead man? You go to work.",
            "I am very, very clear on how difficult it is for a young kid out there to go into the arts without taking a lot of heat from his peers.",
            "I don't know how many hills and valleys I've had, how many times I've had to refocus my world and my life and my career.",
            "I don't know what's on the other side.",
            "I don't want to be a poster child for cancer.",
            "I don't want to be Mr. Romantic Leading Man. I don't want to be the Dance Dude. I don't want to be the Action Guy. If I had to do any one of those all my life, it'd drive me crazy.",
            "I dropped about 20 pounds in the blink of an eye. And then when you see it in the mirror, when all of a sudden you pull your eyes down, and the bottom of your eyes go yellow and jaundice sets in - then you know something's wrong.",
            "I got completely fed up with that Hollywood blockbuster mentality. I couldn't take it seriously any longer.",
            "I had a lot of anger because I wasn't happy with the way I had been raised.",
            "I just love to work hard.",
            "I keep dreaming of a future, a future with a long and healthy life, not lived in the shadow of cancer but in the light.",
            "I keep my heart and my soul and my spirit open to miracles.",
            "I like to believe that I've got a lot of guardian warriors sittin' on my shoulder including my dad.",
            "I took after my father.",
            "I wanna live.",
            "I will go so far as to say probably smoking had something to do with my pancreatic cancer.",
            "I'm trying to shut up and let my angels speak to me and tell me what I'm supposed to do.",
            "I've had so many injuries.",
          ]
        },

        {
          author: ["oprah winfrey", "oprah", "winfrey", "ow", "o"],
          quotes: [
            "Lots of people want to ride with you in the limo, but what you want is someone who will take the bus with you when the limo breaks down.",
            "Be thankful for what you have; you'll end up having more. If you concentrate on what you don't have, you will never, ever have enough.",
            "The more you praise and celebrate your life, the more there is in life to celebrate.",
            "Surround yourself with only people who are going to lift you higher.",
            "Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.",
            "As you become more clear about who you really are, you'll be better able to decide what is best for you - the first time around.",
            "It isn't until you come to a spiritual understanding of who you are - not necessarily a religious feeling, but deep down, the spirit within - that you can begin to take control.",
            "I am a woman in process. I'm just trying like everybody else. I try to take every conflict, every experience, and learn from it. Life is never dull.",
            "Turn your wounds into wisdom.",
            "Doing the best at this moment puts you in the best place for the next moment.",
            "Where there is no struggle, there is no strength.",
            "Do the one thing you think you cannot do. Fail at it. Try again. Do better the second time. The only people who never tumble are those who never mount the high wire. This is your moment. Own it.",
            "Passion is energy. Feel the power that comes from focusing on what excites you.",
            "I don't think of myself as a poor deprived ghetto girl who made good. I think of myself as somebody who from an early age knew I was responsible for myself, and I had to make good.",
            "Think like a queen. A queen is not afraid to fail. Failure is another steppingstone to greatness.",
            "I believe that every single event in life happens in an opportunity to choose love over fear.",
            "The greatest discovery of all time is that a person can change his future by merely changing his attitude.",
            "I don't believe in failure. It is not failure if you enjoyed the process.",
            "I don't think you ever stop giving. I really don't. I think it's an on-going process. And it's not just about being able to write a check. It's being able to touch somebody's life.",
            "The struggle of my life created empathy - I could relate to pain, being abandoned, having people not love me.",
            "What material success does is provide you with the ability to concentrate on other things that really matter. And that is being able to make a difference, not only in your own life, but in other people's lives.",
            "Books were my pass to personal freedom. I learned to read at age three, and soon discovered there was a whole world to conquer that went beyond our farm in Mississippi.",
            "Biology is the least of what makes someone a mother.",
            "Real integrity is doing the right thing, knowing that nobody's going to know whether you did it or not.",
            "I have a lot of things to prove to myself. One is that I can live my life fearlessly."
          ]
        }
      ]

      def random_quote
        set = DATA[rand(DATA.size)]
        [set[:author], set[:quotes][rand(set[:quotes].size)]]
      end

      def the(*args); Exception.new("poorly answered question"); end
      def roof; 0; end
      YO = 0
    end
  end
end
