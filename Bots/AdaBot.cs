using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Bot.Builder;
using Microsoft.Bot.Schema;

namespace AdaBot.Bots
{
    public class AdaBot : ActivityHandler
    {
        public override async Task OnTurnAsync(ITurnContext turnContext, CancellationToken cancellationToken)
        {
            var message = $"[Activity Type]: {turnContext.Activity.Type} \r\n";

            await turnContext.SendActivityAsync(MessageFactory.Text(message, message), cancellationToken);

            await base.OnTurnAsync(turnContext, cancellationToken);
        }

        protected override async Task OnMessageActivityAsync(ITurnContext<IMessageActivity> turnContext, CancellationToken cancellationToken)
        {
            // Text
            var messageText = $"Echo: {turnContext.Activity.Text}";
            await turnContext.SendActivityAsync(MessageFactory.Text(messageText, messageText), cancellationToken);

            // Attachment
            var attachment = new Attachment()
            {
                ContentType = "image/jpeg",
                ContentUrl = "https://example.com/image.jpg"
            };
            await turnContext.SendActivityAsync(MessageFactory.Attachment(attachment), cancellationToken);

            // List of attachments
            var attachments = new List<Attachment>
            {
                new Attachment()
                {
                    ContentType = "image/jpeg",
                    ContentUrl = "https://example.com/image1.jpg"
                },
                new Attachment()
                {
                    ContentType = "image/jpeg",
                    ContentUrl = "https://example.com/image2.jpg"
                }
            };
            await turnContext.SendActivityAsync(MessageFactory.Attachment(attachments), cancellationToken);

            // List of suggested actions
            var actions = new List<CardAction>
            {
                new CardAction() { Title = "Option 1", Type = ActionTypes.ImBack, Value = "Option 1" },
                new CardAction() { Title = "Option 2", Type = ActionTypes.ImBack, Value = "Option 2" },
                new CardAction() { Title = "Option 3", Type = ActionTypes.ImBack, Value = "Option 3" }
            };
            await turnContext.SendActivityAsync(MessageFactory.SuggestedActions(actions, "Choose an option:", null, null), cancellationToken);

            // Carousel of cards
            var heroCard1 = new HeroCard(title: "Card 1", images: new List<CardImage> { new CardImage(url: "https://example.com/card1.jpg") });
            var heroCard2 = new HeroCard(title: "Card 2", images: new List<CardImage> { new CardImage(url: "https://example.com/card2.jpg") });

            var carousels = new List<Attachment>
            {
                heroCard1.ToAttachment(),
                heroCard2.ToAttachment()
            };
            await turnContext.SendActivityAsync(MessageFactory.Carousel(carousels), cancellationToken);

            await turnContext.SendActivityAsync(MessageFactory.ContentUrl("https://example.com/audio.mp3", "audio/mp3"), cancellationToken);
        }

        protected override async Task OnMembersAddedAsync(IList<ChannelAccount> membersAdded, ITurnContext<IConversationUpdateActivity> turnContext, CancellationToken cancellationToken)
        {
            var welcomeText = "Hello and welcome!";
            foreach (var member in membersAdded)
            {
                if (member.Id != turnContext.Activity.Recipient.Id)
                {
                    await turnContext.SendActivityAsync(MessageFactory.Text(welcomeText, welcomeText), cancellationToken);
                }
            }
        }
    }
}
