import { useNavigation } from '@react-navigation/core'
import { useAtom } from 'jotai'
import md5 from 'md5'
import React from 'react'
import { Button, StyleSheet, Text, View } from 'react-native'
import { v4 as uuidv4 } from 'uuid'
import { appSettingsAtom } from '@app/state/settings'
import { getAllKeys, multiRemove } from '@app/storage/asyncstorage'

const TestControls = () => {
  const navigation = useNavigation()

  const removeAllKeys = async () => {
    const allKeys = await getAllKeys()
    await multiRemove(allKeys)
  }

  return (
    <View>
      <Button title="Remove all keys" onPress={removeAllKeys} />
      <Button title="Now Playing" onPress={() => navigation.navigate('now-playing')} />
    </View>
  )
}

const ServerSettingsView = () => {
  const [appSettings, setAppSettings] = useAtom(appSettingsAtom)

  const bootstrapServer = () => {
    if (appSettings.servers.length !== 0) {
      return
    }

    const id = uuidv4()
    const salt = uuidv4()
    const address = 'http://demo.subsonic.org'

    setAppSettings({
      ...appSettings,
      servers: [
        ...appSettings.servers,
        {
          id,
          salt,
          address,
          username: 'guest',
          token: md5('guest' + salt),
        },
      ],
      activeServer: id,
    })
  }

  return (
    <View>
      <Button title="Add default server" onPress={bootstrapServer} />
      {appSettings.servers.map(s => (
        <View key={s.id}>
          <Text style={styles.text}>{s.address}</Text>
          <Text style={styles.text}>{s.username}</Text>
        </View>
      ))}
    </View>
  )
}

const SettingsView = () => (
  <View>
    <TestControls />
    <React.Suspense fallback={<Text>Loading...</Text>}>
      <ServerSettingsView />
    </React.Suspense>
  </View>
)

const styles = StyleSheet.create({
  text: {
    color: 'white',
  },
})

export default SettingsView
