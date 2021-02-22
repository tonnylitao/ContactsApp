import React, {useEffect, useState} from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  FlatList,
  TouchableWithoutFeedback,
  ActivityIndicator,
} from 'react-native';
import {StackScreenProps} from '@react-navigation/stack';
import {Contact} from '@model/Contact';
// @ts-ignore
import {Flag} from 'react-native-svg-flagkit';
import {format} from 'date-fns';
import {style as AppStyle, theme} from '../style';

type RootStackParamList = {
  Home: undefined;
  Profile: Contact;
};

type Props = StackScreenProps<RootStackParamList, 'Home'>;

const Screen = ({navigation}: Props) => {
  const [isLoading, setLoading] = useState(true);
  const [data, setData] = useState([]);

  useEffect(() => {
    fetch('https://randomuser.me/api?page=1&results=20&seed=contacts')
      .then((response) => response.json())
      .then((json) => {
        setTimeout(() => {
          setData(
            json.results.map((item: Contact, index: number) => ({
              ...item,
              userId: index,
              dobString: format(new Date(item.dob.date), 'yyyy-MM-dd'),
            })),
          );
        }, 2000);
      })
      .catch((error) => console.error(error))
      .finally(() => {
        setTimeout(() => {
          setLoading(false);
        }, 2000);
      });
  }, []);

  if (isLoading) {
    return (
      <View style={AppStyle.center}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <FlatList
      data={data}
      renderItem={({item}: {item: Contact}) => (
        <TouchableWithoutFeedback
          onPress={() => {
            navigation.navigate('Profile', item);
          }}>
          <View style={styles.cell}>
            <View style={styles.avatarCnt}>
              <Image
                style={styles.avatar}
                source={{uri: item.picture.thumbnail}}
              />
              <Image
                style={styles.gender}
                source={
                  item.gender === 'male'
                    ? require('../img/ic_male.png')
                    : require('../img/ic_female.png')
                }
              />
            </View>

            <View style={styles.nameCnt}>
              <Text style={styles.name}>
                <Text style={styles.nameTitle}>{item.name.title} </Text>
                {item.name.first} {item.name.last}
              </Text>

              <Text style={styles.dob}>{item.dobString}</Text>
            </View>

            <Flag id={item.nat} width={30} height={20} />
          </View>
        </TouchableWithoutFeedback>
      )}
      keyExtractor={({userId}) => userId.toString()}
    />
  );
};

const styles = StyleSheet.create({
  cell: {
    ...AppStyle.cell,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  avatarCnt: {
    width: theme.width.avatar,
  },
  avatar: {
    width: '100%',
    aspectRatio: 1,
    borderRadius: 22,
  },
  gender: {
    width: 18,
    height: 18,
    borderRadius: 9,
    position: 'absolute',
    right: -5,
    bottom: 0,
  },
  nameCnt: {
    flex: 1,
    marginLeft: theme.padding,
  },
  name: {
    fontSize: theme.fontSize.l,
    marginBottom: 5,
  },
  nameTitle: {
    fontSize: theme.fontSize.m,
    color: theme.color.lightText,
  },
  dob: {
    fontSize: theme.fontSize.s,
    color: theme.color.lightText,
  },
});

export default Screen;
