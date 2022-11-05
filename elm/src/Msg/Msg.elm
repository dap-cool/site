module Msg.Msg exposing (Msg(..), resetViewport)

import Browser
import Browser.Dom as Dom
import Msg.Collector.Collector exposing (FromCollector)
import Msg.Creator.Creator exposing (FromCreator)
import Msg.Js exposing (FromJs)
import Task
import Url


type
    Msg
    -- system
    = NoOp
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
      -- creator
    | FromCreator FromCreator
      -- collector
    | FromCollector FromCollector
      -- js ports
    | FromJs FromJs


resetViewport : Cmd Msg
resetViewport =
    Task.perform (\_ -> NoOp) (Dom.setViewport 0 0)
