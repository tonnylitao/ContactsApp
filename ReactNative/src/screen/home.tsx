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
      <View style={styles.container}>
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
            <View style={styles.avatarContainer}>
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

            <View style={styles.textContainer}>
              <Text style={styles.name}>
                <Text style={styles.userTitle}>{item.name.title} </Text>
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
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  cell: {
    marginLeft: 20,
    marginTop: 20,
    paddingRight: 20,
    paddingBottom: 20,
    flexDirection: 'row',
    borderBottomColor: '#ccc',
    borderStyle: 'solid',
    borderBottomWidth: 0.5,

    justifyContent: 'space-between',
    alignItems: 'center',
  },
  avatarContainer: {
    position: 'relative',
    width: 44,
    height: 44,
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
  },
  textContainer: {
    flex: 1,
    marginLeft: 20,
  },
  name: {
    fontSize: 18,
    marginBottom: 5,
  },
  userTitle: {
    fontSize: 16,
    color: 'rgb(105, 105, 105)',
  },
  gender: {
    width: 18,
    height: 18,
    borderRadius: 9,
    position: 'absolute',
    right: -5,
    bottom: 0,
  },
  dob: {
    fontSize: 14,
    color: 'rgb(105, 105, 105)',
  },
});

export default Screen;
