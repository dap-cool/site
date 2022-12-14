module Msg.Msg exposing (Msg(..), resetViewport)

import Browser
import Browser.Dom as Dom
import Msg.Collector.Collector exposing (FromCollector)
import Msg.Creator.Creator exposing (FromCreator)
import Msg.Global as FromGlobal
import Msg.Js exposing (FromJs)
import Task
import Url


type
    Msg
    -- system
    = NoOp
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
      -- wallet
    | Global FromGlobal.Global
      -- creator
    | FromCreator FromCreator
      -- collector
    | FromCollector FromCollector
      -- exception
    | CloseExceptionModal
      -- js ports
    | FromJs FromJs


resetViewport : Cmd Msg
resetViewport =
    Task.perform (\_ -> NoOp) (Dom.setViewport 0 0)
