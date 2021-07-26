import { artistInfoAtomFamily, useCoverArtUri } from '@app/state/music'
import colors from '@app/styles/colors'
import { useAtomValue } from 'jotai/utils'
import React, { useEffect, useState } from 'react'
import { ActivityIndicator, StyleSheet, View, ViewStyle } from 'react-native'
import FastImage, { ImageStyle } from 'react-native-fast-image'

type BaseProps = {
  imageSize?: 'thumbnail' | 'original'
  style?: ViewStyle
  imageStyle?: ImageStyle
  resizeMode?: keyof typeof FastImage.resizeMode
  round?: boolean
}

type BaseImageProps = BaseProps & {
  enableLoading: () => void
  disableLoading: () => void
  fallbackError: () => void
}

type ArtistIdProp = {
  artistId: string
}

type CoverArtProp = {
  coverArt?: string
}

type ArtistIdImageProps = BaseImageProps & ArtistIdProp
type CoverArtImageProps = BaseImageProps & CoverArtProp

type CoverArtProps = BaseProps & CoverArtProp & Partial<ArtistIdProp>

const ArtistIdImageLoaded = React.memo<ArtistIdImageProps>(
  ({ artistId, imageSize, style, imageStyle, resizeMode, enableLoading, disableLoading, fallbackError }) => {
    const artistInfo = useAtomValue(artistInfoAtomFamily(artistId))

    const uri = imageSize === 'thumbnail' ? artistInfo?.smallImageUrl : artistInfo?.largeImageUrl

    return (
      <FastImage
        source={{ uri }}
        style={[{ height: style?.height, width: style?.width }, imageStyle]}
        resizeMode={resizeMode || FastImage.resizeMode.contain}
        onProgress={enableLoading}
        onLoadEnd={disableLoading}
        onError={fallbackError}
      />
    )
  },
)

const ArtistIdImageFallback: React.FC<{
  enableLoading: () => void
}> = ({ enableLoading }) => {
  useEffect(() => {
    enableLoading()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])
  return <></>
}

const ArtistIdImage = React.memo<ArtistIdImageProps>(props => {
  return (
    <React.Suspense fallback={<ArtistIdImageFallback enableLoading={props.enableLoading} />}>
      <ArtistIdImageLoaded {...props} />
    </React.Suspense>
  )
})

const CoverArtImage = React.memo<CoverArtImageProps>(
  ({ coverArt, imageSize, style, imageStyle, resizeMode, enableLoading, disableLoading, fallbackError }) => {
    const coverArtUri = useCoverArtUri()

    return (
      <FastImage
        source={{ uri: coverArtUri(coverArt, imageSize) }}
        style={[{ height: style?.height, width: style?.width }, imageStyle]}
        resizeMode={resizeMode || FastImage.resizeMode.contain}
        onProgress={enableLoading}
        onLoadEnd={disableLoading}
        onError={fallbackError}
      />
    )
  },
)

const CoverArt: React.FC<CoverArtProps> = ({ coverArt, artistId, resizeMode, imageSize, style, imageStyle, round }) => {
  const [loading, setLoading] = useState(false)
  const [fallback, setFallback] = useState(false)

  const enableLoading = React.useCallback(() => setLoading(true), [])
  const disableLoading = React.useCallback(() => setLoading(false), [])
  const fallbackError = React.useCallback(() => {
    setFallback(true)
    setLoading(false)
  }, [])

  imageSize = imageSize === undefined ? 'thumbnail' : 'original'
  round = round === undefined ? artistId !== undefined : round

  const viewStyles = [style]
  if (round) {
    viewStyles.push(styles.round)
  }

  let ImageComponent
  if (artistId) {
    ImageComponent = (
      <ArtistIdImage
        artistId={artistId}
        imageSize={imageSize}
        style={style}
        imageStyle={imageStyle}
        resizeMode={resizeMode}
        enableLoading={enableLoading}
        disableLoading={disableLoading}
        fallbackError={fallbackError}
      />
    )
  } else {
    ImageComponent = (
      <CoverArtImage
        coverArt={coverArt}
        imageSize={imageSize}
        style={style}
        imageStyle={imageStyle}
        resizeMode={resizeMode}
        enableLoading={enableLoading}
        disableLoading={disableLoading}
        fallbackError={fallbackError}
      />
    )
  }

  if (fallback) {
    ImageComponent = (
      <FastImage
        source={require('@res/fallback.png')}
        style={[{ height: style?.height, width: style?.width }, imageStyle]}
      />
    )
  }

  return (
    <View style={viewStyles}>
      {ImageComponent}
      <ActivityIndicator animating={loading} size="large" color={colors.accent} style={styles.indicator} />
    </View>
  )
}

const styles = StyleSheet.create({
  round: {
    overflow: 'hidden',
    borderRadius: 1000,
  },
  indicator: {
    height: '100%',
    width: '100%',
    position: 'absolute',
  },
})

export default React.memo(CoverArt)
