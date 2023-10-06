// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AutogrowController from "./autogrow_controller"
application.register("autogrow", AutogrowController)

import DropdownController from "./dropdown_controller"
application.register("dropdown", DropdownController)

import MediaTaggingController from "./media_tagging_controller"
application.register("media-tagging", MediaTaggingController)

import MiscController from "./misc_controller"
application.register("misc", MiscController)

import TurboModalController from "./turbo_modal_controller"
application.register("turbo-modal", TurboModalController)

import TweetController from "./tweet_controller"
application.register("tweet", TweetController)

import ConversationController from "./conversation_controller"
application.register("conversation", ConversationController)

import MessageController from "./message_controller"
application.register("message", MessageController)
