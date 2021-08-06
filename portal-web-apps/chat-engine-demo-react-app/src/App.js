// import logo from './logo.svg';
// import './App.css';
import React from 'react';
import {
  ChatEngine,
  ChatList, ChatCard, NewChatForm,
  ChatFeed, ChatHeader, IceBreaker, MessageBubble, IsTyping, ConnectionBar, NewMessageForm,
  ChatSettings, ChatSettingsTop, PeopleSettings, PhotosSettings, OptionsSettings
} from 'react-chat-engine'

function App() {
  return (
    <ChatEngine
      height='100vh'
      projectID={`${process.env.REACT_APP_PROJECT_ID}`}
      userName={`${process.env.REACT_APP_TEST_USERNAME}`}
      userSecret={`${process.env.REACT_APP_TEST_SECRET}`}
      // Customize UI
      renderChatList={(chatAppState) => <ChatList {...chatAppState} />}
      renderChatCard={(chat, index) => <ChatCard key={`${index}`} chat={chat} />}
      renderNewChatForm={(creds) => <NewChatForm creds={creds} />}
      renderChatFeed={(chatAppState) => <ChatFeed {...chatAppState} />}
      renderChatHeader={(chat) => <ChatHeader />}
      renderIceBreaker={(chat) => <IceBreaker />}
      renderMessageBubble={(creds, chat, lastMessage, message, nextMessage) => <MessageBubble lastMessage={lastMessage} message={message} nextMessage={nextMessage} chat={chat} />}
      renderSendingMessage={(creds, chat, lastMessage, message, nextMessage) => <MessageBubble sending={true} lastMessage={lastMessage} message={message} nextMessage={nextMessage} chat={chat} />}
      renderIsTyping={(typers) => <IsTyping />}
      renderConnectionBar={(chat) => <ConnectionBar />}
      renderNewMessageForm={(creds, chatID) => <NewMessageForm />}
      renderChatSettings={(chatAppState) => <ChatSettings {...chatAppState} />}
      renderChatSettingsTop={(creds, chat) => <ChatSettingsTop />}
      renderPeopleSettings={(creds, chat) => <PeopleSettings />}
      renderPhotosSettings={(chat) => <PhotosSettings />}
      renderOptionsSettings={(creds, chat) => <OptionsSettings />}
    />
  );
}

export default App;
