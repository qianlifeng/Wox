import {WoxPreviewType} from "../enums/WoxPreviewTypeEnum.ts";
import {WoxImageType} from "../enums/WoxImageTypeEnum.ts";
import {WoxMessageType} from "../enums/WoxMessageTypeEnum.ts";

declare namespace WOXMESSAGE {

    export interface WoxMessage {
        Id: string
        Method: string
        Type: WoxMessageType
        Success?: bool
        Data: unknown
    }

    export interface WoxPreview {
        PreviewType: WoxPreviewType
        PreviewData: string
        PreviewProperties: { [key: string]: string }
    }

    export interface WoxResultAction {
        Id: string
        Name: string
        IsDefault: boolean
        PreventHideAfterAction: boolean
    }

    export interface WoxImage {
        ImageType: WoxImageType
        ImageData: string
    }

    export interface WoxMessageResponseResult {
        Id: string
        Title: string
        SubTitle: string
        Icon: WoxImage
        Score: number
        AssociatedQuery: string
        Index?: number
        Preview: WoxPreview
        Actions: WoxResultAction[]
    }
}