# Cover Art Archive API wrapper

# Written by Adam Chesak.
# Code released under the MIT open source license.

# Import modules.
import httpclient
import json
import strutils
import strtabs


type
    CoverArtThumbnails* = ref object
        large* : string
        small* : string

    CoverArtImage* = ref object
        types* : seq[string]
        front* : bool
        back* : bool
        edit* : int
        image* : string
        comment* : string
        approved* : bool
        thumbnails* : CoverArtThumbnails
        id* : string

    CoverArtData* = ref object
        images* : seq[CoverArtImage]
        release* : string


proc getCoverArt*(mbid : string): CoverArtData =
    ## Gets the cover art data for the MusicBrainz release with id mbid.
    
    # Create the return object.
    var coverArt : CoverArtData
    
    # Get the data.
    var client = newHttpClient()
    var response : string = client.getContent("http://coverartarchive.org/release/" & mbid)
    
    # Convert the data to JSON.
    var jsonData : JsonNode = parseJson(response)
    
    # Set the fields.
    coverArt.release = jsonData["release"].str
    var coverImgSeq = newSeq[CoverArtImage](len(jsonData["images"]))
    for i in 0..len(jsonData["images"]) - 1:
        
        # Create the image objects.
        var coverImg : CoverArtImage
        if $jsonData["images"][i]["front"] == "true":
            coverImg.front = true
        else:
            coverImg.front = false
        if $jsonData["images"][i]["back"] == "true":
            coverImg.back = true
        else:
            coverImg.back = false
        coverImg.edit = parseInt($jsonData["images"][i]["edit"])
        coverImg.image = jsonData["images"][i]["image"].str
        coverImg.comment = jsonData["images"][i]["comment"].str
        if $jsonData["images"][i]["approved"] == "true":
            coverImg.approved = true
        else:
            coverImg.approved = false
        coverImg.id = jsonData["images"][i]["id"].str
        var coverThumb : CoverArtThumbnails
        coverThumb.large = jsonData["images"][i]["thumbnails"]["large"].str
        coverThumb.small = jsonData["images"][i]["thumbnails"]["small"].str
        coverImg.thumbnails = coverThumb
        var coverTypes = newSeq[string](len(jsonData["images"][i]["types"]))
        for j in 0..len(jsonData["images"][i]["types"]) - 1:
            coverTypes[j] = jsonData["images"][i]["types"][j].str
        coverImg.types = coverTypes
        
        # Append the image object.
        coverImgSeq[i] = coverImg
    
    # Add the sequence of images.
    coverArt.images = coverImgSeq
    
    # Return the cover art data.
    return coverArt


proc getFront*(mbid : string): string = 
    ## Gets the front cover art for the MusicBrainz release with id mbid.
    
    # Get the data.
    var response : Response = newHttpClient().get("http://coverartarchive.org/release/" & mbid & "/front")
    return response.headers["Location"]


proc getBack*(mbid : string): string = 
    ## Gets the back cover art for the MusicBrainz release with id mbid.
    
    # Get the data.
    var response : Response = newHttpClient().get("http://coverartarchive.org/release/" & mbid & "/back")
    return response.headers["Location"]


proc getID*(mbid : string, id : string): string = 
    ## Gets the cover art designated by id for the MusicBrainz release with id mbid.
    
    # Get the data.
    var response : Response = newHttpClient().get("http://coverartarchive.org/release/" & mbid & "/" & id)
    return response.headers["Location"]


proc getThumbnail*(mbid : string, id : string, size : int): string = 
    ## Gets the cover art designated by id for the MusicBrainz release with id mbid. size can be 250 or 500, and id can be either "front", "back", or a cover id.
    
    # Get the data.
    var response : Response = newHttpClient().get("http://coverartarchive.org/release/" & mbid & "/" & id & "-" & intToStr(size))
    return response.headers["Location"]
