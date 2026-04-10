import { application } from "./application"

import AlertController from "./alert_controller"
import FilterController from "./filter_controller"
import SidebarController from "./sidebar_controller"
import DisplayController from "./display_controller"
import GenreFilterController from "./genre_filter_controller"
import ImdbController from "./imdb_controller"
import MusicbrainzController from "./musicbrainz_controller"
import PreviewController from "./preview_controller"
import MoodPromptController from "./mood_prompt_controller"
import SearchInfoController from "./search_info_controller"
import TomSelectController from "./tom_select_controller"
import MosaicMenuController from "./mosaic_menu_controller"
import GetLuckyModalController from "./get_lucky_modal_controller"

application.register("alert", AlertController)
application.register("filter", FilterController)
application.register("sidebar", SidebarController)
application.register("display", DisplayController)
application.register("genre-filter", GenreFilterController)
application.register("imdb", ImdbController)
application.register("musicbrainz", MusicbrainzController)
application.register("preview", PreviewController)
application.register("mood-prompt", MoodPromptController)
application.register("search-info", SearchInfoController)
application.register("tom-select", TomSelectController)
application.register("mosaic-menu", MosaicMenuController)
application.register("get-lucky-modal", GetLuckyModalController)
